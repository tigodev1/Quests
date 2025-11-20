--[[
	ClearWeb Quest Module
	Help Lira clear the spider web from the cave entrance
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

local ClearWeb: QuestData = {
	name = "ClearWeb",
	displayName = "Spider Web Removal",
	description = "Help Lira clear the spider web blocking the cave",

	objectives = {
		{
			id = 1,
			type = "tool",
			description = "• Use Web Cutter",
			event = "WebCutterUsed",
		},
		{
			id = 2,
			type = "talk",
			description = "• Gain Access To Cave",
			event = "LiraWebComplete",
		},
	},

	rewards = {},
	nextQuest = "HiddenVisitor",
}

return ClearWeb
