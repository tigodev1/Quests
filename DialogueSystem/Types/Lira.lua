--[[
	Lira Dialogue Module
	Character: [Add personality description here]
]]

--// Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local DialogModule = require(script.Parent.Parent)

local Lira = {}

--// Quest State
-- Add quest state variables here

--// Dialogue Data
local NODES = {
	start = {
		text = {
			"Hello...",
		},
		options = {
			{text = "Hi!", exit = "Goodbye..."}
		}
	}
}

function Lira.init()
	--// Setup
	local npcModel = Workspace:WaitForChild("Halloween2025"):WaitForChild("Quests"):WaitForChild("NPCS"):WaitForChild("Lira")
	local dialogObject = DialogModule.initializeNPC(npcModel, "Lira", "rbxassetid://132752803178983")

	--// Build Nodes
	for nodeId, nodeData in pairs(NODES) do
		local responses = {}

		for _, option in ipairs(nodeData.options) do
			if option.exit then
				table.insert(responses, {
					text = option.text,
					nextNode = nil,
					action = function(dialog, player)
						dialog:hideGui(option.exit)
					end
				})
			else
				table.insert(responses, {
					text = option.text,
					nextNode = option.next,
					action = nil
				})
			end
		end

		dialogObject:createNode(nodeId, nodeData.text, responses)
	end

	dialogObject:setStartNode("start")
	dialogObject:setGoodbyeMessage("Goodbye...")

	--// Trigger
	dialogObject.prompt.Triggered:Connect(function(player)
		dialogObject:showNode(player)
	end)

	return dialogObject
end

return Lira
