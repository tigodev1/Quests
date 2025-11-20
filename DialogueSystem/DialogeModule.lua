local DialogModule = {}
DialogModule.__index = DialogModule

--// Services
local tweenService = game:GetService("TweenService")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local collectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

--// Constants
local TICK_SOUND = script.sounds.tick
local END_TICK_SOUND = script.sounds.tick2
local DIALOG_RESPONSES_UI =
	Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("dialog"):WaitForChild("dialogResponses")

--// Constructor
function DialogModule.new(npcName, npc, prompt, npcGui, animation)
	local self = setmetatable({}, DialogModule)
	self.npcName = npcName
	self.npc = npc
	self.dialogNodes = {}
	self.currentNode = nil
	self.npcGui = npcGui
	self.active = false
	self.talking = false
	self.prompt = prompt
	self.currentDialogActive = false
	self.goodbyeMessage = "..."
	self.animationTrack = nil

	local template = DIALOG_RESPONSES_UI:FindFirstChild("template")
	if template then
		for i = 1, 9 do
			local newResponseButton = template:Clone()
			newResponseButton.Parent = DIALOG_RESPONSES_UI
			newResponseButton.Name = i
		end
		template:Destroy()
	end

	-- tween variables
	self.animDialogText = tweenService:Create(self.npcGui.dialog, TweenInfo.new(0.3), { TextTransparency = 1 })
	self.animDialogStroke = tweenService:Create(self.npcGui.dialog.UIStroke, TweenInfo.new(0.3), { Transparency = 1 })

	-- Load animation
	if animation ~= nil then
		local humanoid = npc:FindFirstChild("Humanoid")
		if humanoid then
			local newAnimation = Instance.new("Animation")
			newAnimation.AnimationId = animation
			self.animationTrack = humanoid:LoadAnimation(newAnimation)
		end
	end

	-- Connections
	local frameCount = 0
	local heartbeatConnection = runService.Heartbeat:Connect(function()
		frameCount += 1
		if self.talking then
			self.npcGui.StudsOffset = Vector3.new(0, 1.6, 0)
		else
			self.npcGui.StudsOffset = Vector3.new(0, math.sin(frameCount / 25) / 6 + 1.55, 0)
		end
	end)

	self.connections = { heartbeatConnection }

	return self
end

-- Simplified node creation API
function DialogModule:node(nodeId, dialogText)
	local nodeBuilder = {
		_id = nodeId,
		_text = dialogText,
		_responses = {},
		_dialog = self,
	}

	function nodeBuilder:option(responseText, nextNode, action)
		table.insert(self._responses, {
			text = responseText,
			nextNode = nextNode,
			action = action,
		})
		return self
	end

	function nodeBuilder:node(newNodeId, newDialogText)
		self._dialog:createNode(self._id, self._text, self._responses)
		return self._dialog:node(newNodeId, newDialogText)
	end

	function nodeBuilder:setStartNode(startNodeId)
		self._dialog:createNode(self._id, self._text, self._responses)
		return self._dialog:setStartNode(startNodeId)
	end

	return nodeBuilder
end

-- Create a dialogue node (original method, still available)
function DialogModule:createNode(nodeId, dialogText, responses)
	self.dialogNodes[nodeId] = {
		text = dialogText,
		responses = responses or {},
	}
end

-- Set the starting node
function DialogModule:setStartNode(nodeId)
	self.currentNode = nodeId
	return self
end

function DialogModule:setGoodbyeMessage(message)
	self.goodbyeMessage = message
	return self
end

-- Display a specific node's dialog
function DialogModule:showNode(player, nodeId)
	nodeId = nodeId or self.currentNode

	if not nodeId or not self.dialogNodes[nodeId] then
		warn("Node not found:", nodeId)
		return
	end

	-- Prevent multiple dialogues
	if self.currentDialogActive then
		return
	end

	self.currentDialogActive = true
	self:showGui()
	local node = self.dialogNodes[nodeId]

	-- Play animation when dialogue starts
	if self.animationTrack and not self.animationTrack.IsPlaying then
		self.animationTrack:Play()
		self.animationTrack.Looped = true
	end

	tweenService
		:Create(
			workspace.CurrentCamera,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ FieldOfView = 65 }
		)
		:Play()

	task.spawn(function()
		self.talking = true
		local dialogObject = self.npcGui.dialog
		dialogObject.Visible = true

		local texts = type(node.text) == "table" and node.text or { node.text }

		for textIndex, textLine in ipairs(texts) do
			-- Check if player walked away during text display
			local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			local npcRoot = self.npc:FindFirstChild("HumanoidRootPart")

			if playerRoot and npcRoot then
				local distance = (playerRoot.Position - npcRoot.Position).Magnitude
				if distance > 10 then
					self.currentDialogActive = false
					self:hideGui(self.goodbyeMessage)
					return
				end
			end

			dialogObject.Text = ""
			local currenttext = ""
			local skip = false
			local arrow = 0

			for i, letter in string.split(textLine, "") do
				currenttext = currenttext .. letter
				if letter == "<" then
					skip = true
				elseif letter == ">" then
					skip = false
					arrow = arrow + 1
				else
					if arrow == 2 then
						arrow = 0
					end
					if not skip then
						if arrow == 1 then
							dialogObject.Text = currenttext .. "</font>"
						else
							dialogObject.Text = currenttext
						end
						TICK_SOUND:Play()
						task.wait(0.02)
					end
				end
			end
			dialogObject.Text = textLine

			if textIndex < #texts then
				task.wait(1.5)
			end
		end

		self.talking = false

		-- inputs
		local keyboardInputs = {
			Enum.KeyCode.One,
			Enum.KeyCode.Two,
			Enum.KeyCode.Three,
			Enum.KeyCode.Four,
			Enum.KeyCode.Five,
			Enum.KeyCode.Six,
			Enum.KeyCode.Seven,
			Enum.KeyCode.Eight,
			Enum.KeyCode.Nine,
		}

		-- Show responses
		local uiResponses = DIALOG_RESPONSES_UI
		local responseNum = nil
		local connections = {}

		for i, response in ipairs(node.responses) do
			local option = uiResponses[i]

			-- Shorten text display - remove the number prefix for cleaner look
			local displayText = response.text
			if #displayText > 35 then
				displayText = string.sub(displayText, 1, 32) .. "..."
			end
			option.text.Text = "<font color='rgb(255,220,127)'>" .. i .. ".)</font> " .. displayText

			option.Size = UDim2.fromScale(option.Size.X.Scale, 0.4)
			option.text.Position = UDim2.new(0.02, 0, 0.5, 0)
			option.Visible = true
			tweenService
				:Create(
					option,
					TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ Size = UDim2.new(option.Size.X.Scale, 0, 0.35, 0) }
				)
				:Play()

			local enterCon = option.MouseEnter:Connect(function()
				if not self.active then
					return
				end
				tweenService
					:Create(
						option,
						TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ Size = UDim2.new(option.Size.X.Scale, 0, 0.38, 0) }
					)
					:Play()
			end)

			local leaveCon = option.MouseLeave:Connect(function()
				if not self.active then
					return
				end
				tweenService
					:Create(
						option,
						TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ Size = UDim2.new(option.Size.X.Scale, 0, 0.35, 0) }
					)
					:Play()
			end)

			local chooseCon = option.MouseButton1Down:Connect(function()
				if not self.active then
					return
				end
				self.active = false
				responseNum = i
				TICK_SOUND:Play()
			end)

			local numberpressCon = userInputService.InputBegan:Connect(function(input, gameprocessed)
				if gameprocessed then
					return
				end
				if input.UserInputType == Enum.UserInputType.Keyboard then
					local numberinput = table.find(keyboardInputs, input.KeyCode)
					if numberinput ~= nil and numberinput == i then
						if not self.active then
							return
						end
						self.active = false
						responseNum = i
						TICK_SOUND:Play()
					end
				end
			end)

			table.insert(connections, { enterCon, leaveCon, chooseCon, numberpressCon, option })

			END_TICK_SOUND:Play()
			task.wait(0.2)
		end

		self.active = true

		-- Wait for response or player leaving
		local range = 10
		while self.active do
			local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			local npcRoot = self.npc:FindFirstChild("HumanoidRootPart")

			if playerRoot and npcRoot then
				local distance = (playerRoot.Position - npcRoot.Position).Magnitude
				if distance > range then
					self.currentDialogActive = false
					-- Cleanup connections before hiding
					for _, connectionSet in ipairs(connections) do
						connectionSet[1]:Disconnect()
						connectionSet[2]:Disconnect()
						connectionSet[3]:Disconnect()
						connectionSet[4]:Disconnect()
						connectionSet[5].Visible = false
					end
					self:hideGui(self.goodbyeMessage)
					return
				end
			end
			task.wait()
		end

		-- Cleanup connections
		for _, connectionSet in ipairs(connections) do
			connectionSet[1]:Disconnect() -- enterCon
			connectionSet[2]:Disconnect() -- leaveCon
			connectionSet[3]:Disconnect() -- chooseCon
			connectionSet[4]:Disconnect() -- numberpressCon
			connectionSet[5].Visible = false -- Hide option
		end

		-- Handle the chosen response
		if responseNum and responseNum > 0 and node.responses[responseNum] then
			local chosenResponse = node.responses[responseNum]

			-- Run action if it exists
			if chosenResponse.action then
				chosenResponse.action(self, player)
			end

			-- Determine next node
			local nextNode = chosenResponse.nextNode
			if type(nextNode) == "function" then
				nextNode = nextNode(self, player)
			end

			-- Navigate to next node or end dialogue
			if nextNode then
				self.currentNode = nextNode
				self.currentDialogActive = false -- Allow next dialogue to show
				task.wait(0.3)
				self:showNode(player, nextNode)
			else
				-- End dialogue
				self.currentDialogActive = false
				self:hideGui()
			end
		else
			-- Player walked away or no valid response
			self.currentDialogActive = false
			self:hideGui()
		end
	end)
end

function DialogModule:showGui()
	turnProximityPromptsOn(false)

	self.animDialogText:Cancel()
	self.animDialogStroke:Cancel()

	self.npcGui.dialog.TextTransparency = 0
	self.npcGui.dialog.UIStroke.Transparency = 0
end

function DialogModule:hideGui(exitQuip)
	self.active = false
	self.talking = true

	-- Stop animation
	if self.animationTrack and self.animationTrack.IsPlaying then
		self.animationTrack:Stop()
	end

	tweenService
		:Create(
			workspace.CurrentCamera,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ FieldOfView = 70 }
		)
		:Play()

	-- hide player response options
	local playerReponseOptions = DIALOG_RESPONSES_UI
	for i, option in playerReponseOptions:GetChildren() do
		if not option:IsA("GuiButton") then
			continue
		end
		option.Visible = false
	end

	local dialogObject = self.npcGui.dialog
	if exitQuip then
		dialogObject.TextTransparency = 0
		dialogObject.UIStroke.Transparency = 0
		local currenttext = ""
		dialogObject.Text = ""
		dialogObject.Visible = true
		local skip = false
		local arrow = 0
		for i, letter in string.split(exitQuip, "") do
			if dialogObject.Text ~= currenttext and skip == 0 then
				break
			end
			currenttext = currenttext .. letter
			if letter == "<" then
				skip = true
			end
			if letter == ">" then
				skip = false
				arrow += 1
				continue
			end
			if arrow == 2 then
				arrow = 0
			end
			if skip then
				continue
			end
			dialogObject.Text = currenttext .. if arrow == 1 then "</font>" else ""
			TICK_SOUND:Play()
			task.wait(0.02)
		end

		dialogObject.Text = exitQuip
		task.wait(1.5)
	end

	self.talking = false

	task.spawn(function()
		if exitQuip and dialogObject.Text == exitQuip then
			task.wait(1)
		end

		self.animDialogText:Play()
		self.animDialogStroke:Play()

		-- Small delay before re-enabling prompts
		task.wait(0.5)
		turnProximityPromptsOn(true)
	end)
end

function turnProximityPromptsOn(yes)
	for i, prompt in collectionService:GetTagged("NPCprompt") do
		if prompt:IsA("ProximityPrompt") then
			prompt.Enabled = yes
		end
	end
end

-- Weld NPC parts together to prevent movement while allowing animations
local function weldNPC(npc)
	local humanoidRootPart = npc:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		warn("No HumanoidRootPart found for NPC:", npc.Name)
		return
	end

	-- Anchor the HumanoidRootPart
	humanoidRootPart.Anchored = true

	-- For animated NPCs, we need to keep parts unanchored but welded
	for _, part in ipairs(npc:GetDescendants()) do
		if part:IsA("BasePart") and part ~= humanoidRootPart then
			part.Anchored = false

			-- Create weld to HumanoidRootPart
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = humanoidRootPart
			weld.Part1 = part
			weld.Parent = humanoidRootPart
		end
	end
end

-- Initialize an NPC with dialogue system
function DialogModule.initializeNPC(npcModel, npcName, animation)
	-- Get the GUI template from DialogModule
	local guiTemplate = script:WaitForChild("gui")

	-- Weld NPC to prevent movement
	weldNPC(npcModel)

	-- Setup highlight (if it exists in the module)
	local highlightTemplate = script:FindFirstChild("Highlight")
	local highlight = nil
	if highlightTemplate then
		highlight = highlightTemplate:Clone()
		highlight.Enabled = false -- Start disabled
		highlight.Parent = npcModel
	end

	-- Create ProximityPrompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "ProximityPrompt"
	prompt.ActionText = "Talk"
	prompt.ObjectText = npcName
	prompt.MaxActivationDistance = 10
	prompt.Parent = npcModel
	collectionService:AddTag(prompt, "NPCprompt")

	-- Clone and attach GUI to NPC head
	local head = npcModel:WaitForChild("Head")
	local npcGui = guiTemplate:Clone()
	npcGui.Name = "gui"
	npcGui.Parent = head

	-- Create dialog object
	local dialogObject = DialogModule.new(npcName, npcModel, prompt, npcGui, animation)

	if highlight then
		prompt.PromptShown:Connect(function()
			highlight.Enabled = true
		end)

		prompt.PromptHidden:Connect(function()
			highlight.Enabled = false
		end)
	end

	return dialogObject
end

return DialogModule
