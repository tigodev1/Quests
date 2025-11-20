--[[
	HiddenVisitor Quest Module
	Discover the mysterious visitor hidden in the cave
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

local HiddenVisitor: QuestData = {
	name = "HiddenVisitor",
	displayName = "The Hidden Visitor",
	description = "Investigate the mysterious presence in the cave",

	objectives = {
		{
			id = 1,
			type = "custom",
			description = "• Find The Hidden Visitor",
			event = "EnterCave",
		},
		{
			id = 2,
			type = "talk",
			description = "• Interact With Them",
			event = "VisitorQuestTalk",
		},
	},

	rewards = {},
	nextQuest = nil,
}

return HiddenVisitor
