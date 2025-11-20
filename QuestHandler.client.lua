--[[
	QuestHandler - Client-side quest system
	Place in: StarterPlayer > StarterPlayerScripts
]]

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Player
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--// UI
local questsUI = playerGui:WaitForChild("QuestsUI")
local canvas = questsUI:WaitForChild("Canvas")
local list = canvas:WaitForChild("List")

--// Types
type Objective = {
	id: number,
	type: string,
	description: string,
	event: string?,
	target: string?,
}

type QuestData = {
	name: string,
	displayName: string,
	description: string,
	objectives: {Objective},
	rewards: {any},
	nextQuest: string?,
}

--// Quest Handler
local QuestHandler = {}
QuestHandler.activeQuests = {}
QuestHandler.completed = {}
QuestHandler.questModules = {} :: {[string]: QuestData}

--// Load all quest modules
function QuestHandler:loadQuestModules()
	local questsFolder = ReplicatedStorage:WaitForChild("Quests")

	for _, module in ipairs(questsFolder:GetChildren()) do
		if module:IsA("ModuleScript") then
			local success, questData = pcall(require, module)
			if success then
				self.questModules[questData.name] = questData
				print("✅ Loaded quest:", questData.name)
			else
				warn("❌ Failed to load quest module:", module.Name, questData)
			end
		end
	end
end

--// Start a quest
function QuestHandler:startQuest(questName: string)
	local questData = self.questModules[questName]
	if not questData then
		warn("Quest not found:", questName)
		return
	end

	self.activeQuests[questName] = true
	print("🎯 Started quest:", questName)

	for _, objective in ipairs(questData.objectives) do
		self:setupObjective(questName, objective)
	end
end

--// Setup an objective
function QuestHandler:setupObjective(questName: string, objective: Objective)
	local questRemotes = ReplicatedStorage:WaitForChild("QuestRemotes")

	if objective.type == "talk" then
		local remote = questRemotes:WaitForChild(objective.event :: string, 5)
		if remote then
			remote.OnClientEvent:Connect(function()
				self:completeObjective(questName, objective.id)
			end)
		else
			warn("Remote not found:", objective.event)
		end
	end

	if objective.type == "touch" then
		task.spawn(function()
			local hitbox = self:getInstanceFromPath(objective.target :: string)
			if not hitbox then
				warn("Hitbox not found:", objective.target)
				return
			end

			local debounce = false
			hitbox.Touched:Connect(function(hit)
				if debounce then return end

				local character = hit.Parent
				if character and character:FindFirstChild("Humanoid") then
					local touchPlayer = Players:GetPlayerFromCharacter(character)
					if touchPlayer == player then
						debounce = true
						self:completeObjective(questName, objective.id)
					end
				end
			end)

			print("✅ Setup hitbox for:", objective.description)
		end)
	end

	if objective.type == "tool" then
		local remote = questRemotes:WaitForChild(objective.event :: string, 5)
		if remote then
			remote.OnClientEvent:Connect(function()
				self:completeObjective(questName, objective.id)
			end)
			print("✅ Setup tool objective for:", objective.description)
		else
			warn("Remote not found for tool objective:", objective.event)
		end
	end

	if objective.type == "custom" then
		local remote = questRemotes:WaitForChild(objective.event :: string, 5)
		if remote then
			remote.OnClientEvent:Connect(function()
				self:completeObjective(questName, objective.id)
			end)
			print("✅ Setup custom objective for:", objective.description)
		else
			warn("Remote not found for custom objective:", objective.event)
		end
	end
end

--// Get instance from string path
function QuestHandler:getInstanceFromPath(path: string): Instance?
	local parts = path:split(".")
	local current: Instance = game

	for _, part in ipairs(parts) do
		local found = current:WaitForChild(part, 10)
		if not found then
			return nil
		end
		current = found
	end

	return current
end

--// Complete an objective
function QuestHandler:completeObjective(questName: string, objectiveId: number)
	local key = questName .. "_" .. objectiveId

	if self.completed[key] then
		return
	end

	self.completed[key] = true
	print("✅ Completed objective:", objectiveId, "in quest:", questName)

	self:updateObjectiveUI(questName, objectiveId)

	if self:checkQuestComplete(questName) then
		print("🎉 Quest complete:", questName)
		local questRemotes = ReplicatedStorage:WaitForChild("QuestRemotes")
		questRemotes.QuestComplete:FireServer(questName)
	end
end

--// Update objective UI
function QuestHandler:updateObjectiveUI(questName: string, objectiveId: number)
	local questFrame = list:FindFirstChild(questName)
	if not questFrame then
		warn("Quest UI frame not found:", questName)
		return
	end

	local function findObjectiveLabel(parent: Instance, depth: number?): TextLabel?
		depth = depth or 0
		if depth > 10 then return nil end

		for _, child in ipairs(parent:GetChildren()) do
			if child.Name == "Objective" .. objectiveId and child:IsA("TextLabel") then
				return child
			end

			local found = findObjectiveLabel(child, depth + 1)
			if found then return found end
		end
		return nil
	end

	local objectiveLabel = findObjectiveLabel(questFrame)
	if objectiveLabel then
		if not objectiveLabel.Text:find("✓") then
			objectiveLabel.Text = objectiveLabel.Text .. " ✓"
			objectiveLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		end
	else
		warn("Objective label not found:", "Objective" .. objectiveId)
	end
end

--// Check if quest is complete
function QuestHandler:checkQuestComplete(questName: string): boolean
	local questData = self.questModules[questName]
	if not questData then return false end

	for _, objective in ipairs(questData.objectives) do
		local key = questName .. "_" .. objective.id
		if not self.completed[key] then
			return false
		end
	end

	return true
end

--// Setup remote listeners
function QuestHandler:setupRemoteListeners()
	local questRemotes = ReplicatedStorage:WaitForChild("QuestRemotes", 10)
	if not questRemotes then
		warn("QuestRemotes folder not found")
		return
	end

	local objectiveComplete = questRemotes:WaitForChild("ObjectiveComplete", 10)
	if objectiveComplete then
		objectiveComplete.OnClientEvent:Connect(function(questName, objectiveId)
			self:completeObjective(questName, objectiveId)
		end)
	end

	local questComplete = questRemotes:WaitForChild("QuestComplete", 10)
	if questComplete then
		questComplete.OnClientEvent:Connect(function(questName)
			print("🎉 Quest completed (server confirmed):", questName)

			local questFrame = list:FindFirstChild(questName)
			if questFrame then
				task.wait(0.5)
				questFrame.Visible = false
				questFrame:Destroy()
				print("🗑️ Removed completed quest frame:", questName)
			end

			local questData = self.questModules[questName]
			if questData and questData.nextQuest then
				task.wait(1)
				self:startQuest(questData.nextQuest)
			end
		end)
	end
end

--// Initialize
function QuestHandler:init()
	print("🔧 Initializing QuestHandler...")

	task.wait(1)

	self:loadQuestModules()
	self:setupRemoteListeners()
	self:startQuest("StarterQuest")

	print("✅ QuestHandler ready!")
end

QuestHandler:init()

return QuestHandler
