--[[
	Quest Template
	Copy this file and modify it to create new quests
]]

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

local QuestTemplate: QuestData = {
	name = "QuestName",
	displayName = "Display Name",
	description = "Quest description here",

	objectives = {
		{
			id = 1,
			type = "talk", -- Types: "talk", "touch", "tool", "custom"
			description = "• Talk to NPC",
			event = "NPCQuestTalk", -- Remote event name
		},
		-- Add more objectives here
	},

	rewards = {},
	nextQuest = nil, -- Set to next quest name or nil
}

return QuestTemplate
