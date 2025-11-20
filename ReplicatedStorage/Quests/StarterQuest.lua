--[[
	StarterQuest Module
	The first quest players encounter
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

local StarterQuest: QuestData = {
	name = "StarterQuest",
	displayName = "The Beginning",
	description = "Help Valdris and explore the area",

	objectives = {
		{
			id = 1,
			type = "talk",
			description = "• Speak to Valdris",
			event = "ValdrisQuestTalk",
		},
		{
			id = 2,
			type = "touch",
			description = "• Find the Cave",
			target = "Workspace.Halloween2025.Quests.Builds.Cave.Important.Hitbox",
		},
		{
			id = 3,
			type = "talk",
			description = "• Speak to Lira",
			event = "LiraQuestTalk",
		},
		{
			id = 4,
			type = "talk",
			description = "• Return to Valdris",
			event = "ValdrisQuestComplete",
		},
	},

	rewards = {},
	nextQuest = "ClearWeb",
}

return StarterQuest
