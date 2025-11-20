--[[
	Susan Dialogue Module
	Character: Very loving and kind old grandma who believes in myths and legends.
	She's always been interested in one in particular: the golden piano keys treasure.
	Some people refer to her as the town crazy lady for believing in this stuff.
]]

--// Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local DialogModule = require(script.Parent.Parent)

local Susan = {}

--// Quest State
-- Add quest state variables here

--// Dialogue Data
local NODES = {
	start = {
		text = {
			"Oh, hello there, dear! *warm smile*",
			"What a lovely surprise to have a visitor!",
			"Come, come closer... these old bones don't let me speak too loud anymore."
		},
		options = {
			{text = "Hi! Who are you?", next = "introduce"},
			{text = "What are you doing out here?", next = "what_doing"},
			{text = "Goodbye.", exit = "Oh, leaving so soon? Come back anytime, sweetie!"}
		}
	},

	introduce = {
		text = {
			"Oh where are my manners! *chuckles*",
			"I'm <font color='rgb(255,200,220)'>Susan</font>, been living in this town for... oh my...",
			"Must be seventy years now? Maybe eighty? Time flies, dear."
		},
		options = {
			{text = "That's a long time!", next = "long_time"},
			{text = "What do you do here?", next = "what_doing"}
		}
	},

	long_time = {
		text = {
			"Oh it is, it is! *nostalgic smile*",
			"I've seen this town grow from a tiny village...",
			"And I've heard every legend, every story... *eyes sparkle*",
			"Especially the one about the golden treasure in the mountains!"
		},
		options = {
			{text = "Golden treasure?", next = "treasure_intro"},
			{text = "You believe in legends?", next = "believe_legends"}
		}
	},

	what_doing = {
		text = {
			"Well, dear, I spend most of my days here...",
			"Thinking about the old stories, the legends...",
			"People think I'm a bit... *giggles* ...crazy, you know.",
			"But I know what I believe! There's magic in these mountains!"
		},
		options = {
			{text = "What kind of magic?", next = "treasure_intro"},
			{text = "Why do people think you're crazy?", next = "crazy_lady"}
		}
	},

	believe_legends = {
		text = {
			"Oh absolutely, dear! *eyes light up*",
			"I've always believed in the impossible...",
			"Magic, myths, Christmas miracles...",
			"Some call me the 'town crazy lady' *laughs heartily*",
			"But I know there's more to this world than meets the eye!"
		},
		options = {
			{text = "Tell me about the legends.", next = "treasure_intro"},
			{text = "That's actually pretty cool.", next = "cool_response"}
		}
	},

	crazy_lady = {
		text = {
			"*chuckles warmly* Oh, they mean well...",
			"When you're old and talk about golden treasures and magic...",
			"People tend to think you've lost your marbles! *giggles*",
			"But I know what I've heard, what I've read...",
			"The treasure is real, dear. I just know it!"
		},
		options = {
			{text = "What treasure?", next = "treasure_intro"},
			{text = "I believe you.", next = "believe_her"}
		}
	},

	cool_response = {
		text = {
			"Oh, you're so sweet! *pats your shoulder*",
			"It's nice to meet someone who doesn't immediately dismiss an old lady...",
			"Would you like to hear about the treasure, dear?",
			"It's quite the story!"
		},
		options = {
			{text = "Yes, tell me!", next = "treasure_intro"},
			{text = "Maybe another time.", exit = "Of course, dear! Come back whenever you'd like!"}
		}
	},

	believe_her = {
		text = {
			"*eyes well up a little* Oh, you sweet child...",
			"You have no idea how much that means to me...",
			"No one... *voice wavers* ...no one believes me anymore.",
			"Thank you, dear. Truly."
		},
		options = {
			{text = "Tell me about the treasure.", next = "treasure_intro"},
			{text = "You're welcome.", exit = "You're such a kind soul... come visit me again, won't you?"}
		}
	},

	treasure_intro = {
		text = {
			"Ah! *sits up excitedly* The treasure!",
			"Legend says there are golden piano keys...",
			"Hidden deep in a cave up in those mountains! *points*",
			"They say when played, they restore Christmas spirit to the world!",
			"The Carol of Gold, they call it!"
		},
		options = {
			{text = "That sounds amazing!", next = "sounds_amazing"},
			{text = "Do you really believe that?", next = "really_believe"}
		}
	},

	sounds_amazing = {
		text = {
			"Doesn't it?! *beaming with joy*",
			"I've spent years researching, reading old books...",
			"I know exactly where the cave should be!",
			"But... *looks down sadly* ...I'm too old to make the climb anymore.",
			"These bones just won't cooperate, dear."
		},
		options = {
			{text = "I could go look for you!", next = "offer_help"},
			{text = "That's too bad.", next = "too_bad"}
		}
	},

	really_believe = {
		text = {
			"With all my heart, dear! *clutches chest*",
			"I know people think I'm silly...",
			"But I've done my research, studied the old maps...",
			"The cave is real. The treasure is real.",
			"I just... *sighs* ...I can't make the journey anymore."
		},
		options = {
			{text = "I could help you!", next = "offer_help"},
			{text = "Why not ask someone else?", next = "ask_someone"}
		}
	},

	ask_someone = {
		text = {
			"*laughs softly* Oh, I've tried, dear...",
			"Everyone thinks I'm the crazy old lady...",
			"No one takes me seriously anymore.",
			"You're the first person in years to actually listen!",
			"That's why you're so special, sweetie."
		},
		options = {
			{text = "I'll help you find it!", next = "offer_help"},
			{text = "I'm sorry to hear that.", exit = "It's alright, dear... I'm used to it. Come back soon!"}
		}
	},

	offer_help = {
		text = {
			"*gasps* You would?! Oh my goodness!",
			"*tears of joy* You wonderful, wonderful child!",
			"I can't believe... after all these years...",
			"Someone actually wants to help this old lady! *hugs you*"
		},
		options = {
			{text = "Of course! What do I do?", next = "instructions"},
			{text = "What's in it for me?", next = "whats_in_it"}
		}
	},

	too_bad = {
		text = {
			"*looks hopeful* Unless...",
			"Would you be willing to help an old lady?",
			"I know it's a lot to ask from a stranger...",
			"But you seem like such a kind soul!"
		},
		options = {
			{text = "Sure, I'll help!", next = "offer_help"},
			{text = "I don't think so.", exit = "I understand, dear... it was worth asking. Take care!"}
		}
	},

	whats_in_it = {
		text = {
			"*chuckles warmly* Smart question, dear!",
			"Well, I may not have much...",
			"But I have some special items I've collected over the years!",
			"Bring me back anything you find, and I'll reward you handsomely!",
			"Plus... you'd be making an old lady's dream come true! *smiles*"
		},
		options = {
			{text = "Alright, I'm in!", next = "instructions"},
			{text = "I'll think about it.", exit = "Take your time, sweetie! I'll be right here!"}
		}
	},

	instructions = {
		text = {
			"Oh wonderful! *claps hands*",
			"Here's what you need to know, dear...",
			"Head up into the mountains - follow the snow path.",
			"Look for a cave entrance... it should be fairly obvious!",
			"Inside, you might find... well, I'm not sure what!",
			"But anything related to the golden keys would be perfect!"
		},
		options = {
			{text = "Got it! I'll start looking!", exit = "Be safe out there, dear! Come back soon!"},
			{text = "Any other clues?", next = "more_clues"}
		}
	},

	more_clues = {
		text = {
			"Hmm... *thinks hard*",
			"The legend mentions a melody... a secret tune...",
			"And something about a piano... but I'm not sure what!",
			"There might be someone in the cave who knows more...",
			"But be careful, dear! Who knows what you'll find up there!"
		},
		options = {
			{text = "I'll be careful! See you soon!", exit = "Good luck, sweetie! I believe in you!"},
			{text = "This sounds dangerous...", next = "dangerous"}
		}
	},

	dangerous = {
		text = {
			"*gentle smile* You're right to be cautious, dear.",
			"But I have a feeling you're braver than you think!",
			"And besides... sometimes the best treasures...",
			"Are worth a little adventure! *winks*"
		},
		options = {
			{text = "You're right! I'll do it!", exit = "That's the spirit! Go get 'em, dear!"},
			{text = "I need time to prepare.", exit = "Of course! Take all the time you need, sweetie!"}
		}
	}
}

function Susan.init()
	--// Setup
	local npcModel = Workspace:WaitForChild("Halloween2025"):WaitForChild("Quests"):WaitForChild("NPCS"):WaitForChild("Susan")
	local dialogObject = DialogModule.initializeNPC(npcModel, "Susan", "rbxassetid://125859395798479")

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
	dialogObject:setGoodbyeMessage("Take care, dear! Come visit this old lady again soon!")

	--// Trigger
	dialogObject.prompt.Triggered:Connect(function(player)
		dialogObject:showNode(player)
	end)

	return dialogObject
end

return Susan
