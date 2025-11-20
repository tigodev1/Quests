--[[
	QuestServer - Server-side quest system
	Place in: ServerScriptService
	Create "Tools" folder inside this script!
]]

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Types
type PlayerData = {
	currentQuest: string,
	completedQuests: {string},
	completedObjectives: {[string]: boolean},
}

--// Quest Server
local QuestServer = {}
QuestServer.playerData = {} :: {[number]: PlayerData}
QuestServer.questModules = {}

--// Create RemoteEvents folder
local questRemotes = ReplicatedStorage:FindFirstChild("QuestRemotes")
if not questRemotes then
	questRemotes = Instance.new("Folder")
	questRemotes.Name = "QuestRemotes"
	questRemotes.Parent = ReplicatedStorage
end

--// Create remote event
local function createRemote(name: string): RemoteEvent
	local remote = questRemotes:FindFirstChild(name)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = name
		remote.Parent = questRemotes
		print("📡 Created remote:", name)
	end
	return remote :: RemoteEvent
end

--// Core remotes
local objectiveCompleteRemote = createRemote("ObjectiveComplete")
local questCompleteRemote = createRemote("QuestComplete")

--// Load all quest modules
function QuestServer:loadQuestModules()
	local questsFolder = ReplicatedStorage:WaitForChild("Quests", 10)
	if not questsFolder then
		warn("❌ Quests folder not found in ReplicatedStorage!")
		return
	end

	for _, module in ipairs(questsFolder:GetChildren()) do
		if module:IsA("ModuleScript") then
			local success, questData = pcall(require, module)
			if success then
				self.questModules[questData.name] = questData

				for _, objective in ipairs(questData.objectives) do
					if objective.event then
						createRemote(objective.event)
					end
				end

				print("✅ Loaded quest:", questData.name)
			else
				warn("❌ Failed to load quest:", module.Name, questData)
			end
		end
	end
end

--// Tools folder
local toolsFolder = script:FindFirstChild("Tools")
if not toolsFolder then
	toolsFolder = Instance.new("Folder")
	toolsFolder.Name = "Tools"
	toolsFolder.Parent = script
	warn("⚠️ Created Tools folder - add tools with 'Quest' StringAttribute")
end

--// Initialize player data
function QuestServer:initPlayer(player: Player)
	self.playerData[player.UserId] = {
		currentQuest = "StarterQuest",
		completedQuests = {},
		completedObjectives = {},
	}
	print("👤 Initialized player:", player.Name)
end

--// Cleanup player data
function QuestServer:cleanupPlayer(player: Player)
	self.playerData[player.UserId] = nil
	print("👋 Cleaned up player:", player.Name)
end

--// Get player data
function QuestServer:getPlayerData(player: Player): PlayerData?
	return self.playerData[player.UserId]
end

--// Complete objective
function QuestServer:completeObjective(player: Player, questName: string, objectiveId: number)
	local playerData = self:getPlayerData(player)
	if not playerData then
		warn("Player data not found for:", player.Name)
		return
	end

	local key = questName .. "_" .. objectiveId

	if playerData.completedObjectives[key] then
		return
	end

	playerData.completedObjectives[key] = true
	print("✅", player.Name, "completed objective", objectiveId, "in", questName)

	objectiveCompleteRemote:FireClient(player, questName, objectiveId)

	local questData = self.questModules[questName]
	if questData then
		local allComplete = true
		for _, objective in ipairs(questData.objectives) do
			local objKey = questName .. "_" .. objective.id
			if not playerData.completedObjectives[objKey] then
				allComplete = false
				break
			end
		end

		if allComplete then
			self:completeQuest(player, questName)
		end
	end
end

--// Complete quest
function QuestServer:completeQuest(player: Player, questName: string)
	local playerData = self:getPlayerData(player)
	if not playerData then return end

	if table.find(playerData.completedQuests, questName) then
		return
	end

	table.insert(playerData.completedQuests, questName)
	print("🎉", player.Name, "completed quest:", questName)

	self:giveQuestRewards(player, questName)

	questCompleteRemote:FireClient(player, questName)

	local questData = self.questModules[questName]
	if questData and questData.nextQuest then
		playerData.currentQuest = questData.nextQuest
		print("➡️", player.Name, "now on quest:", questData.nextQuest)
	end
end

--// Give quest rewards
function QuestServer:giveQuestRewards(player: Player, questName: string)
	if not player or not player:FindFirstChild("Backpack") then
		return
	end

	for _, tool in ipairs(toolsFolder:GetChildren()) do
		if tool:IsA("Tool") then
			local questAttribute = tool:GetAttribute("Quest")
			if questAttribute == questName then
				local clone = tool:Clone()
				clone.Parent = player.Backpack
				print("🎁 Gave", tool.Name, "to", player.Name)
			end
		end
	end
end

--// Give specific tool to player
function QuestServer:giveTool(player: Player, toolName: string)
	if not player or not player:FindFirstChild("Backpack") then
		return
	end

	local toolFolder = toolsFolder:FindFirstChild(toolName)
	if toolFolder and toolFolder:IsA("Folder") then
		local tool = toolFolder:FindFirstChildWhichIsA("Tool")
		if tool then
			local clone = tool:Clone()
			clone.Parent = player.Backpack
			print("🎁 Gave", tool.Name, "to", player.Name)
		end
	end
end

--// Setup event handlers
function QuestServer:setupEventHandlers()
	questCompleteRemote.OnServerEvent:Connect(function(player, questName)
		self:completeQuest(player, questName)
	end)

	local liraWebQuestAccept = createRemote("LiraWebQuestAccept")
	liraWebQuestAccept.OnServerEvent:Connect(function(player)
		self:giveTool(player, "WebCutter")
		print("🕸️", player.Name, "received WebCutter tool")
	end)

	local webCutterUsed = createRemote("WebCutterUsed")
	webCutterUsed.OnServerEvent:Connect(function(player)
		self:completeObjective(player, "ClearWeb", 1)
		webCutterUsed:FireClient(player)
		print("✂️", player.Name, "used WebCutter")
	end)

	for questName, questData in pairs(self.questModules) do
		for _, objective in ipairs(questData.objectives) do
			if (objective.type == "talk" or objective.type == "custom") and objective.event then
				local remote = questRemotes:FindFirstChild(objective.event)
				if remote and remote:IsA("RemoteEvent") then
					local remoteEvent = remote :: RemoteEvent
					remoteEvent.OnServerEvent:Connect(function(player)
						self:completeObjective(player, questName, objective.id)
						remoteEvent:FireClient(player)
					end)
					print("🔗 Connected event:", objective.event, "for quest:", questName)
				end
			end
		end
	end
end

--// Player management
Players.PlayerAdded:Connect(function(player)
	QuestServer:initPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
	QuestServer:cleanupPlayer(player)
end)

--// Initialize
function QuestServer:init()
	print("🔧 Initializing QuestServer...")

	self:loadQuestModules()
	self:setupEventHandlers()

	print("✅ QuestServer ready!")
end

QuestServer:init()

return QuestServer
