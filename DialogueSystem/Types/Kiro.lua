--[[
	Kiro (Hoffroc) Dialogue Module
	Character: Goofy, seems a little crazy. He's been isolated from society for a good while in cave.
	He's obsessed with one legend he believes is true, so much to the point it's sent him insane.
]]

--// Services
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local DialogModule = require(script.Parent.Parent)

local Kiro = {}

--// Quest State
-- Add quest state variables here

--// Dialogue Data
local NODES = {
	start = {
		text = {
			"*sudden movement* WHO'S THERE?!",
			"Oh... oh! A visitor! A REAL visitor! *laughs maniacally*",
			"I'm <font color='rgb(200,150,100)'>Kiro</font>! Or Hoffroc! I forget which one I like more!",
			"*tilts head* What brings you to my humble cave?!"
		},
		options = {
			{text = "Are you... okay?", next = "are_you_okay"},
			{text = "I'm looking for treasure.", next = "looking_treasure"},
			{text = "This is weird, I'm leaving.", exit = "LEAVING?! But you JUST got here! *cackles* Fine, fine! Go! MORE TREASURE FOR ME!"}
		}
	},

	are_you_okay = {
		text = {
			"Okay?! OKAY?! *spins around*",
			"I'm FANTASTIC! Better than ever!",
			"Been living in this cave for... *counts on fingers* ...many moons!",
			"Lost count! Don't need society! Don't need ANYONE!",
			"Just me... and the LEGEND! *eyes gleam wildly*"
		},
		options = {
			{text = "The legend?", next = "the_legend"},
			{text = "How long have you been here?", next = "how_long"},
			{text = "You seem insane.", next = "seem_insane"}
		}
	},

	looking_treasure = {
		text = {
			"*GASPS* TREASURE?! YOU KNOW ABOUT IT?!",
			"The GOLDEN KEYS?! The Carol of Gold?!",
			"*grabs your shoulders* Tell me you BELIEVE!",
			"Tell me you're not like the others who called me CRAZY!"
		},
		options = {
			{text = "I believe you!", next = "believe_him"},
			{text = "What golden keys?", next = "the_legend"},
			{text = "You're scaring me...", next = "scaring_you"}
		}
	},

	believe_him = {
		text = {
			"*tears up* You... you BELIEVE?!",
			"FINALLY! After all these YEARS!",
			"Someone who doesn't think I'm a lunatic! *laughs*",
			"Well... I AM a bit of a lunatic... BUT I'M RIGHT!"
		},
		options = {
			{text = "Tell me about the keys!", next = "the_legend"},
			{text = "Why are you in this cave?", next = "why_cave"}
		}
	},

	scaring_you = {
		text = {
			"*backs off* Oh! Oh sorry, sorry!",
			"I forget how to... *waves hands* ...people sometimes.",
			"Been alone too long! Cave life! You understand!",
			"*nervous laugh* I'm harmless! Just... excited!"
		},
		options = {
			{text = "It's okay. Tell me about the treasure.", next = "the_legend"},
			{text = "Maybe I should go...", exit = "NO WAIT! I'll be calmer! I promise! ...Fine. GO THEN! *mutters to self*"}
		}
	},

	the_legend = {
		text = {
			"*eyes light up like torches* THE LEGEND!",
			"The Carol of Gold! The golden piano keys!",
			"Once upon a time... *dramatic gesture* ...they brought CHRISTMAS JOY!",
			"But they VANISHED! Hidden away! SEALED!",
			"And Christmas has never been the same! *spins around*"
		},
		options = {
			{text = "Where are they now?", next = "where_keys"},
			{text = "How do you know this?", next = "how_know"},
			{text = "This sounds made up.", next = "sounds_fake"}
		}
	},

	where_keys = {
		text = {
			"HERE! *points wildly* SOMEWHERE HERE!",
			"In these mountains! In THIS CAVE SYSTEM!",
			"But... *whispers conspiratorially* ...it's sealed.",
			"There's a SECRET! A melody! A CODE!",
			"You need to play it on the lobby piano! *giggles*"
		},
		options = {
			{text = "A code? What code?", next = "what_code"},
			{text = "The lobby piano?", next = "lobby_piano"},
			{text = "How do you know this?", next = "how_know"}
		}
	},

	how_know = {
		text = {
			"I've STUDIED! *pulls out tattered papers*",
			"Years and YEARS in this cave!",
			"Reading ancient texts! Deciphering symbols!",
			"Everyone said I was WASTING MY LIFE!",
			"But I KNEW! I knew the truth! *cackles*"
		},
		options = {
			{text = "So what's the secret?", next = "what_code"},
			{text = "Why did you isolate yourself?", next = "why_cave"}
		}
	},

	sounds_fake = {
		text = {
			"*eyes widen* FAKE?! FAKE?!",
			"That's what THEY said! *points at nothing*",
			"That's why I'm HERE! Alone! ISOLATED!",
			"Because NO ONE believed me!",
			"But I'll PROVE IT! And you'll see! YOU'LL ALL SEE! *maniacal laugh*"
		},
		options = {
			{text = "Okay, okay! I believe you!", next = "believe_him"},
			{text = "Prove it then.", next = "prove_it"}
		}
	},

	prove_it = {
		text = {
			"*grins wildly* PROVE IT?! I'LL PROVE IT!",
			"I have part of the code! THE MELODY!",
			"Some of the notes you need to play!",
			"The rest... *taps head* ...are hidden around!",
			"Numbers! Clues! PUZZLES! *giggles*"
		},
		options = {
			{text = "Give me the code!", next = "give_code"},
			{text = "Where are the other notes?", next = "where_notes"}
		}
	},

	what_code = {
		text = {
			"The MELODY! *hums tunelessly*",
			"You play it on the lobby piano and...",
			"*makes explosion gesture* ...the REAL cave opens!",
			"This cave? *looks around* Just the entrance!",
			"The TREASURE is in the HIDDEN chamber!"
		},
		options = {
			{text = "Can you tell me the melody?", next = "give_code"},
			{text = "How do you know it works?", next = "how_know_works"}
		}
	},

	lobby_piano = {
		text = {
			"Yes! YES! The piano in the lobby!",
			"It's not just decoration! *taps nose*",
			"It's the KEY! Literally! A musical key!",
			"Play the right notes in the right order...",
			"And the mountain itself will SING! *laughs*"
		},
		options = {
			{text = "What are the notes?", next = "give_code"},
			{text = "This is insane.", next = "this_insane"}
		}
	},

	this_insane = {
		text = {
			"INSANE?! *laughs hysterically*",
			"Of course it's INSANE!",
			"The best truths always SOUND insane!",
			"That's how they stay HIDDEN!",
			"But I'm RIGHT! And you'll SEE!"
		},
		options = {
			{text = "Fine. Tell me the code.", next = "give_code"},
			{text = "I can't deal with this.", exit = "YOUR LOSS! More treasure for ME! *cackles as you leave*"}
		}
	},

	give_code = {
		text = {
			"*rummages through papers frantically*",
			"HERE! *shoves notes at you*",
			"These are SOME of the notes! Not all!",
			"The rest... *giggles* ...are scattered!",
			"Hidden around the map! With NUMBERS!",
			"Find them! Play the melody! UNLOCK THE TRUTH!"
		},
		options = {
			{text = "Where are they hidden?", next = "where_notes"},
			{text = "Why don't you get them?", next = "why_not_you"}
		}
	},

	where_notes = {
		text = {
			"*waves hands vaguely* EVERYWHERE!",
			"I hid some! Others were already there!",
			"Look for NUMBERS! Look for CLUES!",
			"Around buildings! In corners! UP HIGH! DOWN LOW!",
			"It's a TREASURE HUNT! *spins around excitedly*"
		},
		options = {
			{text = "I'll find them!", next = "will_find"},
			{text = "This seems complicated.", next = "seems_complicated"}
		}
	},

	why_not_you = {
		text = {
			"ME?! *laughs nervously*",
			"I... I can't leave the cave.",
			"I've been here too long! The outside is... SCARY!",
			"Too many people! Too much NOISE!",
			"You do it! You're braver! STRONGER! *hides behind rock*"
		},
		options = {
			{text = "Alright, I'll do it.", next = "will_find"},
			{text = "You're scared of people?", next = "scared_people"}
		}
	},

	scared_people = {
		text = {
			"*peeks out* Maybe! A little! A LOT!",
			"They didn't BELIEVE me!",
			"Called me crazy! INSANE! A fool!",
			"So I came here! Where I'm SAFE!",
			"Where the LEGEND is REAL! *hugs self*"
		},
		options = {
			{text = "I'll help you prove it.", next = "will_find"},
			{text = "That's really sad.", next = "really_sad"}
		}
	},

	really_sad = {
		text = {
			"*looks down* Sad? Maybe...",
			"But also... EXCITING! *perks up*",
			"Because YOU'RE here! And you might BELIEVE!",
			"And then... and then the treasure will be FOUND!",
			"And everyone will know I was RIGHT! *giggles madly*"
		},
		options = {
			{text = "I'll find the notes.", next = "will_find"},
			{text = "What happens after?", next = "what_after"}
		}
	},

	will_find = {
		text = {
			"*grabs your hands* YOU WILL?!",
			"Oh THANK YOU! THANK YOU!",
			"This is it! This is FINALLY IT!",
			"Go! GO! Find the notes! Play the melody!",
			"And bring me the GOLDEN KEYS! *eyes gleaming*"
		},
		options = {
			{text = "I'll bring them back!", exit = "YES! YES! Go! Hurry! The treasure AWAITS! *cackles with glee*"},
			{text = "What's my reward?", next = "whats_reward"}
		}
	},

	whats_reward = {
		text = {
			"*pauses* Reward? REWARD?!",
			"The treasure itself! The GLORY!",
			"You'll be a HERO! A legend!",
			"And... *thinks* ...I have shiny rocks?",
			"Cave trinkets? My ETERNAL GRATITUDE?! *hopeful smile*"
		},
		options = {
			{text = "That works for me!", exit = "EXCELLENT! Now GO! The mountain calls! *pushes you gently*"},
			{text = "I want part of the treasure.", next = "want_treasure"}
		}
	},

	want_treasure = {
		text = {
			"*narrows eyes* Part of it?",
			"...FINE! Yes! Take some!",
			"I just want to PROVE I was right!",
			"The keys! The legend! The TRUTH!",
			"You can have gold! I want VINDICATION! *laughs*"
		},
		options = {
			{text = "Deal! I'll find it!", exit = "GO FORTH, BRAVE SOUL! Make history! *waves frantically*"}
		}
	},

	what_after = {
		text = {
			"After? *eyes glaze over*",
			"After... I'll be RIGHT!",
			"Everyone will KNOW! The legend is REAL!",
			"Maybe... maybe I can leave the cave again...",
			"Maybe people will LISTEN... *hopeful look*"
		},
		options = {
			{text = "I'll help you.", next = "will_find"},
			{text = "Good luck with that.", exit = "I don't need luck! I have YOU! Or... had you. BYE! *waves*"}
		}
	},

	seems_complicated = {
		text = {
			"Complicated?! No no no!",
			"It's SIMPLE! *counts on fingers*",
			"Find notes! Play melody! Get treasure!",
			"See?! THREE STEPS! EASY! *grins wildly*",
			"You can DO IT! I BELIEVE in you!"
		},
		options = {
			{text = "Alright, I'll try.", next = "will_find"},
			{text = "I don't think so.", exit = "NO?! But... but... *slumps* ...fine. Go. LEAVE ME! *dramatic*"}
		}
	},

	how_know_works = {
		text = {
			"I DON'T! *laughs*",
			"But the texts say so! The symbols!",
			"And I FEEL it! In my BONES!",
			"Call it... *taps head* ...insane intuition!",
			"Or maybe I'm just CRAZY! *giggles* But it'll WORK!"
		},
		options = {
			{text = "I trust you. Let's do it.", next = "will_find"},
			{text = "This is too risky.", exit = "RISKY?! Life is RISK! But fine! Run away! *waves dismissively*"}
		}
	},

	why_cave = {
		text = {
			"*sits down heavily* Why the cave?",
			"Because... *looks around fondly* ...it's QUIET here.",
			"No one to tell me I'm WRONG!",
			"No one to LAUGH at me!",
			"Just me and the LEGEND and the TRUTH!",
			"It's... *smiles* ...peaceful. In a crazy way."
		},
		options = {
			{text = "I understand.", next = "understand"},
			{text = "Don't you get lonely?", next = "get_lonely"}
		}
	},

	understand = {
		text = {
			"*looks up surprised* You... you do?",
			"That's... *voice cracks* ...that's nice.",
			"Not many people... understand.",
			"Thank you. *genuine smile*"
		},
		options = {
			{text = "Let's find that treasure.", next = "will_find"},
			{text = "You're welcome.", exit = "You're kind. Come back soon! *waves happily*"}
		}
	},

	get_lonely = {
		text = {
			"Lonely? *thinks* ...Yes. Sometimes.",
			"But the LEGEND keeps me company!",
			"And now... *grins* ...YOU'RE here!",
			"So I'm not lonely RIGHT NOW! *laughs*"
		},
		options = {
			{text = "I'll help you find it.", next = "will_find"},
			{text = "I should go.", exit = "Already?! Oh... okay. Come back! Please! *hopeful*"}
		}
	},

	how_long = {
		text = {
			"*counts on fingers* ...Lost track!",
			"Years? Decades? EONS?!",
			"Time is WEIRD in caves! *spins*",
			"But long enough to KNOW the legend!",
			"Long enough to find the TRUTH!"
		},
		options = {
			{text = "What truth?", next = "the_legend"},
			{text = "That's a long time.", exit = "It IS! But worth it! WORTH IT! Bye! *waves*"}
		}
	},

	seem_insane = {
		text = {
			"*tilts head* Insane? ME?!",
			"*bursts out laughing* YES! Probably!",
			"But the BEST people are! *grins*",
			"Sane is BORING! I'm INTERESTING!",
			"And I'm RIGHT! About the treasure! You'll SEE!"
		},
		options = {
			{text = "Tell me about it.", next = "the_legend"},
			{text = "I'm leaving.", exit = "Suit yourself! More GLORY for me! *cackles*"}
		}
	}
}

function Kiro.init()
	--// Setup
	local npcModel = Workspace:WaitForChild("Halloween2025"):WaitForChild("Quests"):WaitForChild("NPCS"):WaitForChild("Kiro")
	local dialogObject = DialogModule.initializeNPC(npcModel, "Kiro", "rbxassetid://125859395798479")

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
	dialogObject:setGoodbyeMessage("Come back! COME BACK! I'll be here! In the cave! WAITING! *laughs maniacally*")

	--// Trigger
	dialogObject.prompt.Triggered:Connect(function(player)
		dialogObject:showNode(player)
	end)

	return dialogObject
end

return Kiro
