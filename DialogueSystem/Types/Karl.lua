--[[
	Karl Dialogue Module
	Character: A pretty simple guy who likes playing piano.
	He only wants you to do a simple thing and offers a cool little item.
	He likes shortening words whilst talking (e.g. 'I'm gonna play piano')
]]

--// Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local DialogModule = require(script.Parent.Parent)

local Karl = {}

--// Quest State
-- Add quest state variables here

--// Dialogue Data
local NODES = {
	start = {
		text = {
			"Oh hey! Whatcha doin' here?",
			"I'm <font color='rgb(100,180,255)'>Karl</font>, just chillin' by my piano."
		},
		options = {
			{text = "You play piano?", next = "piano_talk"},
			{text = "Just looking around.", next = "looking_around"},
			{text = "Gotta go.", exit = "Aight, see ya 'round!"}
		}
	},

	piano_talk = {
		text = {
			"Oh yeah! I'm gonna play some tunes later.",
			"Been playin' for like... I dunno... forever? *laughs*",
			"It's kinda my thing, y'know?"
		},
		options = {
			{text = "That's cool!", next = "thats_cool"},
			{text = "Can you play something?", next = "play_something"},
			{text = "Not really interested.", exit = "Alright, no worries! Catch ya later!"}
		}
	},

	looking_around = {
		text = {
			"Fair 'nough! There's lotsa stuff to see 'round here.",
			"But lemme tell ya... *leans in*",
			"If you're gonna explore, keep an eye out for candy canes!",
			"I'm tryna collect 'em all!"
		},
		options = {
			{text = "Candy canes?", next = "candy_canes"},
			{text = "Why do you want them?", next = "why_candy_canes"}
		}
	},

	thats_cool = {
		text = {
			"Thanks! *grins*",
			"Yeah, I'm pretty into it.",
			"Wanna know somethin' cool tho?",
			"I'm also collectin' candy canes! Tryna find 'em all!"
		},
		options = {
			{text = "Candy canes? Why?", next = "why_candy_canes"},
			{text = "Where are they?", next = "where_candy_canes"}
		}
	},

	play_something = {
		text = {
			"Haha, maybe later!",
			"I'm gonna practice some new stuff first.",
			"Plus, I'm kinda busy lookin' for somethin' right now.",
			"Candy canes, actually! They're scattered all over."
		},
		options = {
			{text = "Candy canes?", next = "candy_canes"},
			{text = "I could help find them!", next = "offer_help"}
		}
	},

	candy_canes = {
		text = {
			"Yeah! There's like... a bunch of 'em hidden 'round the map.",
			"Red and white, pretty easy to spot if you're payin' attention.",
			"I'm gonna use 'em to make somethin' special!"
		},
		options = {
			{text = "Make what?", next = "make_what"},
			{text = "Sounds fun!", next = "sounds_fun"}
		}
	},

	why_candy_canes = {
		text = {
			"Well, I'm gonna make a candy cane lantern!",
			"It's gonna look sick! *excited*",
			"But I need all the candy canes I can find to make it work.",
			"Problem is... I'm kinda lazy. *scratches head*"
		},
		options = {
			{text = "A candy cane lantern?", next = "make_what"},
			{text = "I could help!", next = "offer_help"}
		}
	},

	make_what = {
		text = {
			"A candy cane lantern! It's gonna be so cool!",
			"Lights up all festive-like... gonna put it right here by the piano.",
			"But I gotta collect like... I dunno... maybe ten? Twenty?",
			"Haven't really counted 'em all yet. *shrugs*"
		},
		options = {
			{text = "I'll help you find them!", next = "offer_help"},
			{text = "That's a lot of work.", next = "lot_of_work"}
		}
	},

	sounds_fun = {
		text = {
			"Right?! I think so too!",
			"Only thing is... I'm not really in the mood to go searchin'.",
			"I'd rather just chill here and play piano, y'know?",
			"Unless... *looks at you hopefully*"
		},
		options = {
			{text = "Unless what?", next = "unless_what"},
			{text = "I could search for you!", next = "offer_help"}
		}
	},

	unless_what = {
		text = {
			"Unless you're gonna help me out! *grins*",
			"I mean, no pressure or anythin'...",
			"But if you bring me the candy canes...",
			"I'll give ya somethin' cool in return!"
		},
		options = {
			{text = "Sure, I'll do it!", next = "accept_quest"},
			{text = "What's the reward?", next = "whats_reward"}
		}
	},

	offer_help = {
		text = {
			"Oh for real?! That'd be awesome!",
			"I'm not gonna lie, I'm kinda lazy 'bout this stuff. *laughs*",
			"But if you're willin' to help...",
			"I'll totally hook you up with somethin' nice!"
		},
		options = {
			{text = "Deal! What do I do?", next = "accept_quest"},
			{text = "What's the reward?", next = "whats_reward"}
		}
	},

	lot_of_work = {
		text = {
			"Yeah... that's why I haven't done it yet. *laughs*",
			"I'm more of a 'sit and play piano' kinda guy.",
			"But hey, if you're up for it...",
			"I'll make it worth your while!"
		},
		options = {
			{text = "Alright, I'll help.", next = "accept_quest"},
			{text = "Nah, too much.", exit = "Haha, fair! Can't blame ya. See ya!"}
		}
	},

	whats_reward = {
		text = {
			"Oh! Right, yeah...",
			"I got this cool candy cane lantern I'm gonna make.",
			"Once I got all the canes, I'll make one for you too!",
			"Or maybe somethin' else... I got a lotta random stuff lyin' around.",
			"Trust me, it'll be worth it!"
		},
		options = {
			{text = "Sounds good! I'm in!", next = "accept_quest"},
			{text = "I'll think about it.", exit = "Cool, cool. Lemme know if ya change your mind!"}
		}
	},

	accept_quest = {
		text = {
			"Sick! Okay, here's what you gotta do...",
			"Just look 'round the map for candy canes.",
			"They're kinda hidden but not too hard to find.",
			"Bring 'em back to me whenever you got 'em!",
			"I'm gonna be here playin' piano anyway. *grins*"
		},
		options = {
			{text = "Got it! I'll start looking!", exit = "Awesome! Good luck out there!"},
			{text = "How many do you need?", next = "how_many"}
		}
	},

	how_many = {
		text = {
			"Uh... *thinks*",
			"Honestly? I dunno exactly.",
			"Just grab whatever you can find, I guess?",
			"More is better, y'know? Can't have too many candy canes!",
			"I'll let ya know when we got enough!"
		},
		options = {
			{text = "Alright, I'll find them!", exit = "You're the best! Gonna play some tunes while I wait!"},
			{text = "That's not very specific...", next = "not_specific"}
		}
	},

	not_specific = {
		text = {
			"Haha, yeah I know... *scratches head*",
			"I'm not super organized with this stuff.",
			"Just bring me what ya find and we'll figure it out!",
			"I'm pretty chill 'bout it, don't stress!"
		},
		options = {
			{text = "Okay, I'll do my best!", exit = "That's all I'm askin'! Catch ya later!"},
			{text = "This seems disorganized.", exit = "Eh, that's just how I roll! See ya 'round!"}
		}
	},

	where_candy_canes = {
		text = {
			"All over the place, really!",
			"I've seen a couple near the spawn area...",
			"Maybe some by the trees? Behind buildings?",
			"Honestly, I haven't looked too hard. *laughs*",
			"That's kinda why I need help!"
		},
		options = {
			{text = "I'll help you find them!", next = "offer_help"},
			{text = "Good luck with that.", exit = "Haha, thanks! You too!"}
		}
	}
}

function Karl.init()
	--// Setup
	local npcModel = Workspace:WaitForChild("Halloween2025"):WaitForChild("Quests"):WaitForChild("NPCS"):WaitForChild("Karl")
	local dialogObject = DialogModule.initializeNPC(npcModel, "Karl", "rbxassetid://125859395798479")

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
	dialogObject:setGoodbyeMessage("Aight, peace out! Gonna go play some piano!")

	--// Trigger
	dialogObject.prompt.Triggered:Connect(function(player)
		dialogObject:showNode(player)
	end)

	return dialogObject
end

return Karl
