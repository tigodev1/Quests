--[[
	Umbra Dialogue Module
	A mysterious figure hidden in the cave depths
	Speaks in cryptic but helpful ways
]]

--// Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local DialogModule = require(script.Parent.Parent)

local Umbra = {}

--// Dialogue Data
local NODES = {
	-- Initial meeting (Quest objective 1 complete - entering cave)
	quest_start = {
		text = {
			"...",
			"You found me.",
			"Few venture this deep... fewer still with purpose."
		},
		responses = {
			{text = "Who are you?", node = "introduction"},
			{text = "What are you doing here?", node = "purpose"}
		}
	},

	introduction = {
		text = {
			"I am called Umbra.",
			"A watcher. An observer of shadows.",
			"I've lingered in these depths, away from prying eyes."
		},
		responses = {
			{text = "Why hide here?", node = "whyHide"},
			{text = "What do you watch?", node = "whatWatch"}
		}
	},

	purpose = {
		text = {
			"Watching. Waiting.",
			"The cave whispers secrets to those who listen.",
			"But you... you didn't come to listen, did you?"
		},
		responses = {
			{text = "No, I came to find you", node = "foundMe"},
			{text = "What secrets?", node = "secrets"}
		}
	},

	whyHide = {
		text = {
			"Hide? No...",
			"I simply observe from where I'm unseen.",
			"The surface world moves too quickly. Here, time slows."
		},
		responses = {
			{text = "I see...", node = "questComplete"}
		}
	},

	whatWatch = {
		text = {
			"Everything. Nothing.",
			"The patterns in the darkness. The flow of energy.",
			"You, for instance... I sensed you clearing that web."
		},
		responses = {
			{text = "You've been watching me?", node = "questComplete"}
		}
	},

	foundMe = {
		text = {
			"Indeed you did.",
			"Most impressive. The cave does not reveal its secrets easily.",
			"Perhaps you're more than you appear."
		},
		responses = {
			{text = "Perhaps...", node = "questComplete"}
		}
	},

	secrets = {
		text = {
			"Secrets best left whispered, not spoken.",
			"But I sense you're trustworthy.",
			"The cave remembers all who enter. You've left your mark."
		},
		responses = {
			{text = "Interesting...", node = "questComplete"}
		}
	},

	questComplete = {
		text = {
			"You've proven yourself curious and capable.",
			"The shadows recognize you now.",
			"Feel free to linger in the depths... or return to the surface."
		},
		responses = {
			{text = "Thank you", exit = "The shadows welcome you, wanderer."}
		}
	},

	-- After quest completion
	after_quest = {
		text = {
			"Back already?",
			"The shadows remember you."
		},
		responses = {
			{text = "Just checking in", node = "justVisiting"},
			{text = "Goodbye", exit = "May the shadows guide you."}
		}
	},

	justVisiting = {
		text = {
			"The cave appreciates visitors who respect its silence.",
			"Feel free to linger."
		},
		responses = {
			{text = "Goodbye", exit = "Farewell, wanderer."}
		}
	}
}

--// Quest State
local questComplete = false

function Umbra.init()
	--// Setup
	local npcModel = Workspace:WaitForChild("Halloween2025"):WaitForChild("Quests"):WaitForChild("NPCS"):WaitForChild("Umbra")
	local dialogObject = DialogModule.initializeNPC(npcModel, "Umbra", "rbxassetid://125859395798479")

	--// Get quest remotes
	local questRemotes = ReplicatedStorage:WaitForChild("QuestRemotes", 10)
	local visitorQuestTalk = questRemotes:WaitForChild("VisitorQuestTalk", 10)

	--// Listen for quest completion
	visitorQuestTalk.OnClientEvent:Connect(function()
		questComplete = true
		print("✅ Hidden Visitor quest complete")
	end)

	--// Dynamic node selection
	dialogObject.getStartNode = function()
		if questComplete then
			return "after_quest"
		else
			return "quest_start"
		end
	end

	--// Set dialogue tree
	dialogObject.dialogueTree = NODES

	--// Fire quest completion on first interaction
	dialogObject.onDialogueComplete = function()
		if not questComplete then
			visitorQuestTalk:FireServer()
		end
	end

	print("✅ Umbra dialogue initialized")
end

return Umbra
