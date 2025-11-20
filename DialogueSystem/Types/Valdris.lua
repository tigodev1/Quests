--// Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local DialogModule = require(script.Parent.Parent)

local Valdris = {}

--// Quest State
local hasStartedQuest = false
local readyToReturn = false
local questComplete = false

--// Dialogue Data
local NODES = {
	-- Quest Start Node
	quest_start = {
		text = {
			"Oh.. hey there..",
			"I need.. mmm.. some help..",
			"Can you.. help me?.. please?.."
		},
		options = {
			{text = "Sure, what do you need?", next = "quest_accept"},
			{text = "Maybe later.", exit = "Ah.. okay.. *sigh*.. I understand.."}
		}
	},

	quest_accept = {
		text = {
			"Great! So.. um..",
			"I need you to.. explore a bit..",
			"Find the cave.. and talk to Lira..",
			"She's.. also alone.. like me.. haha.."
		},
		options = {
			{text = "Got it!", exit = "Thanks.. *smiles*.. I appreciate you.."}
		}
	},

	quest_in_progress = {
		text = {
			"Still working on.. those tasks?..",
			"Take your time.. no rush.. *yawns*.."
		},
		options = {
			{text = "I'll get it done.", exit = "I know you will.. *smiles softly*.."}
		}
	},

	quest_return = {
		text = {
			"Oh! You're back.. *perks up*..",
			"You.. you actually did it.. wow..",
			"Here's a reward for your time.. *hands you something*..",
			"Thank you.. really.. *genuine smile*.."
		},
		options = {
			{text = "You're welcome!", exit = "Come back anytime.. *happy sigh*.. I mean it.."}
		}
	},

	quest_completed = {
		text = {
			"Hey again.. *smiles*..",
			"Thanks for everything you did..",
			"It meant a lot.. haha..",
			"Oh.. *remembers*.. Lira mentioned something..",
			"She might have.. a new quest for you.. if you're interested.."
		},
		options = {
			{text = "I'll check it out!", exit = "Great.. she'll appreciate it.. *smiles*.. see you.."},
			{text = "Maybe later.", exit = "That's fine.. *awkward wave*.. take care.."}
		}
	},
	start = {
		text = {
			"Oh.. mmm.. hello there..",
			"I didn't think anyone would.. ah.. actually stop by..",
			"This is.. heh.. slightly embarrassing.."
		},
		options = {
			{text = "You okay?", next = "okay_check"},
			{text = "Who are you?", next = "introduce"},
			{text = "Uh.. bye.", exit = "Oh.. yeah.. that's.. totally fair.. haha.."}
		}
	},

	okay_check = {
		text = {
			"Me? Oh I'm.. *sigh*.. I'm fine..",
			"Just.. you know.. existing.. being dramatic..",
			"The usual vampire stuff.. haha.. sorry.."
		},
		options = {
			{text = "Wait, you're a vampire?!", next = "vampire_reveal"},
			{text = "That's.. weird.", exit = "Yeah I.. I get that a lot.. *nervous laugh*.."}
		}
	},

	introduce = {
		text = {
			"Ah.. right.. introductions..",
			"I'm <font color='rgb(180,30,30)'>Valdris</font>.. mmm..",
			"I was supposed to be this.. big scary prince but.. heh..",
			"I'm more of a.. *yawns*.. sleepy disaster really.."
		},
		options = {
			{text = "A prince?", next = "prince_story"},
			{text = "You seem tired.", next = "tired"},
			{text = "This is too weird.", exit = "Ah.. yeah.. sorry for being.. whatever this is.. haha.."}
		}
	},

	vampire_reveal = {
		text = {
			"Oh.. did I not.. *sigh*.. mention that?",
			"Yeah I'm.. mmm.. technically undead..",
			"But like.. the lamest kind.. I promise.. haha.."
		},
		options = {
			{text = "Are you going to bite me?", next = "bite_question"},
			{text = "How does that work?", next = "how_vampire"}
		}
	},

	bite_question = {
		text = {
			"What?! No! God no.. *laughs*..",
			"I mean.. I could but.. that's so.. awkward?..",
			"Like.. 'hey can I.. sip your blood?' No thanks.. haha..",
			"I mostly just.. eat sandwiches.. honestly.."
		},
		options = {
			{text = "Vampires eat sandwiches?", next = "sandwich"},
			{text = "You're the weirdest vampire.", exit = "Heh.. yeah.. I really am.. sorry about that.."}
		}
	},

	sandwich = {
		text = {
			"Oh yeah.. all the time..",
			"Turkey and.. mmm.. Swiss cheese.. you know..",
			"The blood thing is.. overrated.. and messy.. *yawns*..",
			"Sandwiches are just.. easier.. haha.."
		},
		options = {
			{text = "That's actually adorable.", next = "adorable_response"},
			{text = "I have questions.", next = "questions"}
		}
	},

	adorable_response = {
		text = {
			"*blushes* Oh.. haha.. um..",
			"That's.. wow.. no one's ever.. *nervous laugh*..",
			"You're making this weird.. in a good way?.. maybe?..",
			"Ah.. *covers face*.. this is so embarrassing.."
		},
		options = {
			{text = "You're really dramatic.", next = "dramatic"},
			{text = "I should probably go.", exit = "Oh.. right.. yeah.. um.. thanks for.. existing I guess?.. haha.."}
		}
	},

	dramatic = {
		text = {
			"I KNOW RIGHT?! *sigh*..",
			"I try so hard to be.. mysterious and cool but..",
			"I just end up being.. *gestures vaguely*.. whatever this is..",
			"Mmm.. tragic comedy vampire.. haha.."
		},
		options = {
			{text = "I like it honestly.", next = "like_it"},
			{text = "This is exhausting.", exit = "Haha.. yeah.. sorry.. I'll just.. be over here.. bye.."}
		}
	},

	like_it = {
		text = {
			"You.. you do?.. *perks up*..",
			"Oh my god that's.. haha.. that's so nice..",
			"Most people just.. run away screaming.. or laugh.. both valid..",
			"But you're.. you're actually.. wow.. *smiles*.. thank you.."
		},
		options = {
			{text = "You're welcome, Valdris.", exit = "Ah.. *happy sigh*.. come back anytime.. maybe.. if you want.. no pressure.. haha.."},
			{text = "Tell me more about you.", next = "more_story"}
		}
	},

	prince_story = {
		text = {
			"Oh.. *sigh*.. that old story..",
			"Yeah I used to be.. mmm.. royalty?..",
			"Crimson Court.. castles.. the whole dramatic thing..",
			"But honestly it was.. so exhausting.. haha.."
		},
		options = {
			{text = "What happened?", next = "what_happened"},
			{text = "Sounds fancy.", exit = "It was but.. *yawns*.. too much effort.. you know?.. bye.."}
		}
	},

	what_happened = {
		text = {
			"Oh.. um.. everyone kinda.. died..",
			"Stakes.. pitchforks.. the usual mob stuff.. *nervous laugh*..",
			"I hid in a closet.. which is.. not very princely but.. heh..",
			"And now I'm just.. here.. being weird.. alone.. mmm.."
		},
		options = {
			{text = "That's actually sad.", next = "actually_sad"},
			{text = "At least you survived?", next = "survived"}
		}
	},

	actually_sad = {
		text = {
			"Ah.. yeah.. I guess it is.. *sigh*..",
			"I try not to think about it too much..",
			"But like.. four hundred years alone.. haha..",
			"It's.. mmm.. a lot.. you know?.."
		},
		options = {
			{text = "You're not alone now.", next = "not_alone"},
			{text = "I'm sorry.", exit = "It's okay.. really.. thanks for listening.. haha.. bye.."}
		}
	},

	not_alone = {
		text = {
			"*looks up* Oh..",
			"That's.. *voice cracks*.. that's really sweet..",
			"Haha.. wow.. I wasn't expecting that..",
			"Thank you.. seriously.. *smiles softly*.."
		},
		options = {
			{text = "Anytime, friend.", exit = "Friend.. *happy sigh*.. I like that.. see you soon?.. maybe?.. haha.."},
			{text = "Want to talk more?", next = "talk_more"}
		}
	},

	talk_more = {
		text = {
			"Really?! Oh my god yes.. *excited*..",
			"I mean.. *clears throat*.. if you want.. casual.. cool.. mmm..",
			"Haha sorry I'm just.. not used to people actually.. staying..",
			"This is.. wow.. nice.. thank you.."
		},
		options = {
			{text = "Tell me a secret.", next = "secret"},
			{text = "What do you do all day?", next = "daily_life"}
		}
	},

	secret = {
		text = {
			"A secret?.. oh.. um.. *thinks*..",
			"Okay so.. I collect.. tiny spoons.. haha..",
			"Like the little decorative ones.. from different places..",
			"It's so dumb but.. *sigh*.. they make me happy.. mmm.."
		},
		options = {
			{text = "That's the cutest thing ever.", exit = "*blushes* OKAY BYE NOW.. haha.. come back soon.. maybe.."},
			{text = "Why spoons?", next = "why_spoons"}
		}
	},

	why_spoons = {
		text = {
			"I don't know honestly.. *laughs*..",
			"They're just.. small.. shiny.. pointless..",
			"Kind of like me.. haha.. *self-deprecating laugh*..",
			"But in a.. fun way?.. maybe?.. mmm.."
		},
		options = {
			{text = "You're not pointless.", exit = "Ah.. *tears up*.. okay.. thank you.. wow.. haha.. bye.."},
			{text = "That's hilarious.", exit = "Heh.. glad I could.. entertain?.. see you.. maybe.. haha.."}
		}
	}
}

function Valdris.init()
	--// Setup
	local npcModel = Workspace:WaitForChild("Halloween2025"):WaitForChild("Quests"):WaitForChild("NPCS"):WaitForChild("Valdris")
	local dialogObject = DialogModule.initializeNPC(npcModel, "Valdris", "rbxassetid://125859395798479")

	--// Get quest remotes (server creates these automatically)
	local questRemotes = ReplicatedStorage:WaitForChild("QuestRemotes", 10)
	local valdrisQuestTalk = questRemotes:WaitForChild("ValdrisQuestTalk", 10)
	local valdrisQuestComplete = questRemotes:WaitForChild("ValdrisQuestComplete", 10)
	local liraQuestTalk = questRemotes:WaitForChild("LiraQuestTalk", 10)

	--// Listen for Lira quest completion to know when player can return
	liraQuestTalk.OnClientEvent:Connect(function()
		readyToReturn = true
		print("✅ Ready to return to Valdris")
	end)

	--// Listen for quest completion confirmation
	valdrisQuestComplete.OnClientEvent:Connect(function()
		questComplete = true
		print("✅ StarterQuest completed!")
	end)

	--// Build Nodes
	for nodeId, nodeData in pairs(NODES) do
		local responses = {}

		for _, option in ipairs(nodeData.options) do
			if option.exit then
				table.insert(responses, {
					text = option.text,
					nextNode = nil,
					action = function(dialog, player)
						if nodeId == "quest_accept" and not hasStartedQuest then
							hasStartedQuest = true
							valdrisQuestTalk:FireServer()
						elseif nodeId == "quest_return" and not questComplete then
							valdrisQuestComplete:FireServer()
						end
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
	dialogObject:setGoodbyeMessage("Oh.. leaving?.. haha.. yeah.. um.. bye.. *awkward wave*..")

	--// Trigger with dynamic start node
	dialogObject.prompt.Triggered:Connect(function(player)
		if questComplete then
			dialogObject.currentNode = "quest_completed"
		elseif readyToReturn then
			dialogObject.currentNode = "quest_return"
		elseif hasStartedQuest then
			dialogObject.currentNode = "quest_in_progress"
		else
			dialogObject.currentNode = "quest_start"
		end

		dialogObject:showNode(player)
	end)

	return dialogObject
end

return Valdris
