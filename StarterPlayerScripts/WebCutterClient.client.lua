--[[
	WebCutterClient
	Handles client-side WebCutter functionality (ProximityPrompt + Minigame)
	Tool is given by server, this script only adds the client behavior
]]

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local WebCutterHandler = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("WebCutterHandler"))

--// Variables
local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

local activeHandlers = {}

--// Get web mesh
local function getWebMesh()
	local success, result = pcall(function()
		return workspace:WaitForChild("Halloween2025", 10)
			:WaitForChild("Quests", 10)
			:WaitForChild("Builds", 10)
			:WaitForChild("Cave", 10)
			:WaitForChild("Important", 10)
			:WaitForChild("Web", 10)
	end)

	if success then
		return result
	else
		warn("⚠️ Could not find web mesh:", result)
		return nil
	end
end

--// Setup tool when received from server
local function setupWebCutter(tool: Tool)
	if activeHandlers[tool] then return end

	local webMesh = getWebMesh()
	if not webMesh then
		warn("⚠️ Web mesh not found, cannot setup WebCutter")
		return
	end

	local handler = WebCutterHandler.new(tool, webMesh)
	activeHandlers[tool] = handler
	print("✅ WebCutter initialized client-side")

	tool.AncestryChanged:Connect(function()
		if not tool.Parent then
			task.wait(0.1)
			if not tool.Parent and activeHandlers[tool] then
				activeHandlers[tool]:destroy()
				activeHandlers[tool] = nil
			end
		end
	end)
end

--// Watch backpack for server-given tool
backpack.ChildAdded:Connect(function(child)
	if child.Name == "WebCutter" and child:IsA("Tool") then
		task.wait(0.1)
		setupWebCutter(child)
	end
end)

--// Check if tool already exists
for _, tool in ipairs(backpack:GetChildren()) do
	if tool.Name == "WebCutter" and tool:IsA("Tool") then
		setupWebCutter(tool)
	end
end

--// Handle character respawn
player.CharacterAdded:Connect(function(character)
	character.ChildAdded:Connect(function(child)
		if child.Name == "WebCutter" and child:IsA("Tool") then
			task.wait(0.1)
			setupWebCutter(child)
		end
	end)
end)
