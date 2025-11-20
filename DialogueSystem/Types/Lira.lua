--[[
Personality Traits for Lira:
In same place as Valdris reference wise

Dry, depressing, sad, somewhat comedy but not too much, sarcastic
- Melancholic but with dry humor
- More direct than Valdris but still awkward
- Self-aware about her sadness
- Sarcastic undertones
]]

--// Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local DialogModule = require(script.Parent.Parent)

local Lira = {}

--// Quest State
local questObjectiveMet = false
local valdrisReturnComplete = false
local spiderQuestOffered = false
local spiderQuestAccepted = false
local webCleared = false

--// Dialogue Data
local NODES = {
	quest_objective = {
		text = {
			"Oh.. great.. another person..",
			"Valdris sent you.. didn't he..",
			"Look.. I've got a spider problem.. *sighs*..",
			"Can you.. help?.. Or is that too much to ask?.."
		},
		options = {
			{text = "Sure, I'll help.", next = "quest_accept_spider"},
			{text = "A spider? Really?", next = "spider_details"}
		}
	},

	spider_details = {
		text = {
			"Yes.. a spider.. *deadpan*..",
			"A big one.. because of course it is..",
			"My life is just.. one inconvenience after another..",
			"But yeah.. it's actually a problem.. so.."
		},
		options = {
			{text = "Okay, I'll deal with it.", next = "quest_accept_spider"},
			{text = "That sounds terrifying.", exit = "Tell me about it.. *sigh*.. whatever.."}
		}
	},

	quest_accept_spider = {
		text = {
			"Oh.. wow.. you're actually helping..",
			"That's.. surprisingly nice..",
			"Thanks I guess.. *weak smile*.."
		},
		options = {
			{text = "...", exit = "Yeah.. bye.. I'll just.. be here.. existing.."}
		}
	},

	spider_web_quest = {
		text = {
			"Oh.. you're back..",
			"So.. there's a spider web.. *sighs*..",
			"It's blocking the cave entrance.. of course it is..",
			"Can you.. cut it down?.. Please?.."
		},
		options = {
			{text = "Sure, I'll help.", next = "web_quest_accept"},
			{text = "Why don't you do it?", next = "why_not_you"}
		}
	},

	why_not_you = {
		text = {
			"Me?.. *scoffs*..",
			"I tried.. the spider just.. stares at me..",
			"It's very judgmental.. and I don't need that negativity..",
			"So.. yeah.. can you just.. do it?.."
		},
		options = {
			{text = "Fine, I'll do it.", next = "web_quest_accept"},
			{text = "This is ridiculous.", exit = "Tell me about it.. *sigh*.. whatever.."}
		}
	},

	web_quest_accept = {
		text = {
			"Thank you.. *relieved sigh*..",
			"Here.. take this Web Cutter..",
			"Just.. equip it near the web and.. cut it..",
			"Come back when you're done.. I guess.."
		},
		options = {
			{text = "Got it.", exit = "Yeah.. good luck.. *waves weakly*.."}
		}
	},

	web_cleared_return = {
		text = {
			"Oh.. you actually did it..",
			"The web is gone.. wow..",
			"I can finally.. access the cave.. *small smile*..",
			"Thanks.. I mean it.. that was.. nice of you.."
		},
		options = {
			{text = "No problem!", exit = "Yeah.. *genuine smile*.. come back anytime.."},
			{text = "What's in the cave?", next = "cave_info"}
		}
	},

	cave_info = {
		text = {
			"The cave?.. oh.. just.. old stuff..",
			"Artifacts.. memories.. spider webs apparently..",
			"Nothing too exciting.. but it's mine.. so.. yeah.."
		},
		options = {
			{text = "Sounds mysterious.", exit = "It's really not.. but thanks.. *smirks*.. bye.."}
		}
	},

	web_quest_complete = {
		text = {
			"Hey.. thanks again for.. you know..",
			"Clearing that web.. it really helped..",
			"I appreciate it.. more than I show.. probably.."
		},
		options = {
			{text = "Anytime!", exit = "Yeah.. see you around.. *nods*.."}
		}
	},

	start = {
		text = {
			"Oh.. hey..",
			"I'm <font color='rgb(140,90,180)'>Lira</font>.. unfortunately..",
			"Welcome to my.. *gestures vaguely*.. sad little corner.."
		},
		options = {
			{text = "You okay?", next = "okay_check"},
			{text = "Why unfortunately?", next = "why_unfortunately"}
		}
	},

	okay_check = {
		text = {
			"Am I okay?.. haha.. *dry laugh*..",
			"Define okay..",
			"I'm alive.. technically.. so.. sure.."
		},
		options = {
			{text = "That's concerning.", next = "concerning"},
			{text = "Fair enough.", exit = "Yeah.. it is what it is.. bye.."}
		}
	},

	concerning = {
		text = {
			"Is it though?..",
			"I've been like this for.. centuries..",
			"At this point it's just.. my personality.. *shrugs*.."
		},
		options = {
			{text = "That's actually sad.", next = "actually_sad"},
			{text = "You're weird.", exit = "Yeah I get that a lot.. cool.. bye.."}
		}
	},

	actually_sad = {
		text = {
			"It is sad.. you're right..",
			"But hey.. at least I'm self-aware about it..",
			"That counts for something.. maybe.. probably not.."
		},
		options = {
			{text = "I like your honesty.", exit = "Thanks.. I think.. that's.. nice.. bye.."},
			{text = "Want to talk about it?", next = "talk_about_it"}
		}
	},

	talk_about_it = {
		text = {
			"Talk about it?.. huh..",
			"No one's ever.. actually asked that..",
			"I don't know what to do with this.. *awkward*.."
		},
		options = {
			{text = "It's okay, take your time.", next = "take_time"},
			{text = "Forget I asked.", exit = "Yeah that's.. more on brand.. bye.."}
		}
	},

	take_time = {
		text = {
			"Okay.. um.. *clears throat*..",
			"I'm just.. tired.. you know?..",
			"Tired of being alone.. tired of the darkness..",
			"But like.. in a cool goth way.. not a sad way.. *nervous laugh*.."
		},
		options = {
			{text = "You're not alone now.", next = "not_alone"},
			{text = "That's deep.", exit = "Yeah.. too deep.. sorry.. bye.."}
		}
	},

	not_alone = {
		text = {
			"I.. oh..",
			"That's.. *voice cracks*.. actually really sweet..",
			"I wasn't expecting that.. wow.. um.. thanks.."
		},
		options = {
			{text = "Anytime.", exit = "Okay.. yeah.. *smiles softly*.. come back sometime.. maybe.."},
			{text = "You deserve better.", next = "deserve_better"}
		}
	},

	deserve_better = {
		text = {
			"I.. *speechless*..",
			"No one's ever.. said that to me..",
			"I don't know how to.. process this.. *emotional*.."
		},
		options = {
			{text = "It's true though.", exit = "Thank you.. *wipes eyes*.. seriously.. bye.."}
		}
	},

	why_unfortunately = {
		text = {
			"Because being me is.. exhausting..",
			"Constant melancholy.. dramatic sighs..",
			"It's a whole thing.. *sighs dramatically*.."
		},
		options = {
			{text = "I think it's charming.", next = "charming"},
			{text = "Sounds exhausting.", exit = "It really is.. *yawns*.. bye.."}
		}
	},

	charming = {
		text = {
			"Charming?.. me?.. *surprised*..",
			"That's.. the nicest thing I've heard in.. decades..",
			"You're making me feel things.. it's weird.. but nice.."
		},
		options = {
			{text = "Good weird?", next = "good_weird"},
			{text = "You're welcome.", exit = "Yeah.. thanks.. *genuine smile*.. see you.."}
		}
	},

	good_weird = {
		text = {
			"Yeah.. good weird.. I think..",
			"It's been so long since I felt.. anything positive..",
			"This is.. nice.. thank you.."
		},
		options = {
			{text = "Happy to help.", exit = "You did help.. more than you know.. bye.."}
		}
	}
}

function Lira.init()
	--// Setup
	local npcModel = Workspace:WaitForChild("Halloween2025"):WaitForChild("Quests"):WaitForChild("NPCS"):WaitForChild("Lira")
	local dialogObject = DialogModule.initializeNPC(npcModel, "Lira", "rbxassetid://132752803178983")

	--// Get quest remotes (server creates these automatically)
	local questRemotes = ReplicatedStorage:WaitForChild("QuestRemotes", 10)
	local liraQuestTalk = questRemotes:WaitForChild("LiraQuestTalk", 10)
	local liraWebQuestAccept = questRemotes:WaitForChild("LiraWebQuestAccept", 10)
	local webCutterUsed = questRemotes:WaitForChild("WebCutterUsed", 10)
	local liraWebComplete = questRemotes:WaitForChild("LiraWebComplete", 10)
	local valdrisQuestComplete = questRemotes:WaitForChild("ValdrisQuestComplete", 10)

	--// Listen for Valdris quest completion (StarterQuest finished)
	valdrisQuestComplete.OnClientEvent:Connect(function()
		valdrisReturnComplete = true
	end)

	--// Listen for web being cut
	webCutterUsed.OnClientEvent:Connect(function()
		webCleared = true
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
						if nodeId == "quest_accept_spider" and not questObjectiveMet then
							questObjectiveMet = true
							liraQuestTalk:FireServer()
						elseif nodeId == "web_quest_accept" and not spiderQuestAccepted then
							spiderQuestAccepted = true
							liraWebQuestAccept:FireServer()
						elseif nodeId == "web_cleared_return" and not spiderQuestOffered then
							spiderQuestOffered = true
							liraWebComplete:FireServer()
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
	dialogObject:setGoodbyeMessage("Yeah.. leaving.. I get it.. *sigh*.. bye..")

	--// Trigger with dynamic start node
	dialogObject.prompt.Triggered:Connect(function(player)
		if spiderQuestOffered then
			dialogObject.currentNode = "web_quest_complete"
		elseif webCleared then
			dialogObject.currentNode = "web_cleared_return"
		elseif spiderQuestAccepted then
			dialogObject.currentNode = "start"
		elseif valdrisReturnComplete then
			dialogObject.currentNode = "spider_web_quest"
		elseif questObjectiveMet then
			dialogObject.currentNode = "start"
		else
			dialogObject.currentNode = "quest_objective"
		end

		dialogObject:showNode(player)
	end)

	return dialogObject
end

return Lira
