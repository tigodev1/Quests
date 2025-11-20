--[[
	WebCutterHandler Module
	Manages ProximityPrompt, tool behavior, and challenging timing-based minigame
]]

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local WebCutterHandler = {}
WebCutterHandler.__index = WebCutterHandler

--// Minigame Constants
local SLASHES_REQUIRED = 8
local BASE_INDICATOR_SPEED = 1.2
local SPEED_INCREASE_PER_HIT = 0.15
local PERFECT_ZONE_SIZE = 0.12
local GOOD_ZONE_SIZE = 0.28
local MISS_PENALTY = -1

function WebCutterHandler.new(tool: Tool, webMesh: BasePart)
	local self = setmetatable({}, WebCutterHandler)

	self.tool = tool
	self.webMesh = webMesh
	self.player = Players.LocalPlayer
	self.proximityPrompt = nil
	self.isEquipped = false
	self.checkConnection = nil

	self.gui = nil
	self.slashesComplete = 0
	self.isMinigameActive = false
	self.indicatorPosition = 0.5
	self.indicatorDirection = 1
	self.updateConnection = nil
	self.currentSpeed = BASE_INDICATOR_SPEED

	self:setupTool()

	return self
end

function WebCutterHandler:setupTool()
	self.tool.Equipped:Connect(function()
		self.isEquipped = true
		self:startDistanceCheck()
	end)

	self.tool.Unequipped:Connect(function()
		self.isEquipped = false
		self:stopDistanceCheck()
		self:removeProximityPrompt()
	end)
end

function WebCutterHandler:startDistanceCheck()
	if self.checkConnection then return end

	self.checkConnection = RunService.Heartbeat:Connect(function()
		if not self.isEquipped then
			self:stopDistanceCheck()
			return
		end

		self:checkDistance()
	end)
end

function WebCutterHandler:stopDistanceCheck()
	if self.checkConnection then
		self.checkConnection:Disconnect()
		self.checkConnection = nil
	end
end

function WebCutterHandler:checkDistance()
	if not self.player.Character then return end
	if not self.webMesh or not self.webMesh.Parent then return end

	local humanoidRootPart = self.player.Character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local distance = (humanoidRootPart.Position - self.webMesh.Position).Magnitude

	if distance <= 15 then
		self:createProximityPrompt()
	else
		self:removeProximityPrompt()
	end
end

function WebCutterHandler:createProximityPrompt()
	if self.proximityPrompt then return end

	self.proximityPrompt = Instance.new("ProximityPrompt")
	self.proximityPrompt.ActionText = "Cut"
	self.proximityPrompt.ObjectText = "Spider Web"
	self.proximityPrompt.MaxActivationDistance = 10
	self.proximityPrompt.RequiresLineOfSight = false
	self.proximityPrompt.Parent = self.webMesh

	self.proximityPrompt.Triggered:Connect(function(playerWhoTriggered)
		if playerWhoTriggered == self.player then
			self:openMinigame()
		end
	end)
end

function WebCutterHandler:removeProximityPrompt()
	if self.proximityPrompt then
		self.proximityPrompt:Destroy()
		self.proximityPrompt = nil
	end
end

--// UI Creation
function WebCutterHandler:createUI()
	local playerGui = self.player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "WebCutterGui"
	screenGui.Enabled = false
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 550, 0, 450)
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 20)
	uiCorner.Parent = mainFrame

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(180, 100, 200)
	uiStroke.Thickness = 4
	uiStroke.Parent = mainFrame

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -40, 0, 70)
	title.Position = UDim2.new(0, 20, 0, 20)
	title.BackgroundTransparency = 1
	title.Text = "⚔️ CUT THE WEB! ⚔️"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 36
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.TextStrokeTransparency = 0.5
	title.Parent = mainFrame

	local slashCounter = Instance.new("TextLabel")
	slashCounter.Name = "SlashCounter"
	slashCounter.Size = UDim2.new(0, 120, 0, 70)
	slashCounter.Position = UDim2.new(1, -140, 0, 20)
	slashCounter.BackgroundTransparency = 1
	slashCounter.Text = "0/" .. SLASHES_REQUIRED
	slashCounter.TextColor3 = Color3.fromRGB(150, 200, 255)
	slashCounter.TextSize = 32
	slashCounter.Font = Enum.Font.GothamBold
	slashCounter.TextStrokeTransparency = 0.5
	slashCounter.Parent = mainFrame

	local speedLabel = Instance.new("TextLabel")
	speedLabel.Name = "SpeedLabel"
	speedLabel.Size = UDim2.new(0, 100, 0, 30)
	speedLabel.Position = UDim2.new(0, 20, 0, 20)
	speedLabel.BackgroundTransparency = 1
	speedLabel.Text = "SPEED: 1x"
	speedLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
	speedLabel.TextSize = 18
	speedLabel.Font = Enum.Font.GothamBold
	speedLabel.TextXAlignment = Enum.TextXAlignment.Left
	speedLabel.TextStrokeTransparency = 0.5
	speedLabel.Parent = mainFrame

	local timingBar = Instance.new("Frame")
	timingBar.Name = "TimingBar"
	timingBar.Size = UDim2.new(0.88, 0, 0, 70)
	timingBar.Position = UDim2.new(0.5, 0, 0, 160)
	timingBar.AnchorPoint = Vector2.new(0.5, 0)
	timingBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	timingBar.BorderSizePixel = 0
	timingBar.Parent = mainFrame

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 15)
	barCorner.Parent = timingBar

	local barStroke = Instance.new("UIStroke")
	barStroke.Color = Color3.fromRGB(100, 100, 120)
	barStroke.Thickness = 2
	barStroke.Parent = timingBar

	local perfectZone = Instance.new("Frame")
	perfectZone.Name = "PerfectZone"
	perfectZone.Size = UDim2.new(PERFECT_ZONE_SIZE, 0, 1, 0)
	perfectZone.Position = UDim2.new(0.5, 0, 0, 0)
	perfectZone.AnchorPoint = Vector2.new(0.5, 0)
	perfectZone.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
	perfectZone.BorderSizePixel = 0
	perfectZone.ZIndex = 2
	perfectZone.Parent = timingBar

	local perfectCorner = Instance.new("UICorner")
	perfectCorner.CornerRadius = UDim.new(0, 12)
	perfectCorner.Parent = perfectZone

	local goodZone = Instance.new("Frame")
	goodZone.Name = "GoodZone"
	goodZone.Size = UDim2.new(GOOD_ZONE_SIZE, 0, 1, 0)
	goodZone.Position = UDim2.new(0.5, 0, 0, 0)
	goodZone.AnchorPoint = Vector2.new(0.5, 0)
	goodZone.BackgroundColor3 = Color3.fromRGB(255, 220, 100)
	goodZone.BorderSizePixel = 0
	goodZone.ZIndex = 1
	goodZone.Parent = timingBar

	local goodCorner = Instance.new("UICorner")
	goodCorner.CornerRadius = UDim.new(0, 12)
	goodCorner.Parent = goodZone

	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.Size = UDim2.new(0, 10, 1.5, 0)
	indicator.Position = UDim2.new(0.5, 0, 0.5, 0)
	indicator.AnchorPoint = Vector2.new(0.5, 0.5)
	indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	indicator.BorderSizePixel = 0
	indicator.ZIndex = 3
	indicator.Parent = timingBar

	local indicatorCorner = Instance.new("UICorner")
	indicatorCorner.CornerRadius = UDim.new(1, 0)
	indicatorCorner.Parent = indicator

	local indicatorGlow = Instance.new("UIStroke")
	indicatorGlow.Color = Color3.fromRGB(255, 255, 255)
	indicatorGlow.Thickness = 3
	indicatorGlow.Transparency = 0.3
	indicatorGlow.Parent = indicator

	local slashButton = Instance.new("TextButton")
	slashButton.Name = "SlashButton"
	slashButton.Size = UDim2.new(0.65, 0, 0, 90)
	slashButton.Position = UDim2.new(0.5, 0, 0, 270)
	slashButton.AnchorPoint = Vector2.new(0.5, 0)
	slashButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
	slashButton.BorderSizePixel = 0
	slashButton.Text = "⚡ SLASH! ⚡"
	slashButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	slashButton.TextSize = 32
	slashButton.Font = Enum.Font.GothamBold
	slashButton.TextStrokeTransparency = 0.5
	slashButton.Parent = mainFrame

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 15)
	buttonCorner.Parent = slashButton

	local buttonStroke = Instance.new("UIStroke")
	buttonStroke.Color = Color3.fromRGB(255, 100, 100)
	buttonStroke.Thickness = 3
	buttonStroke.Parent = slashButton

	local feedbackLabel = Instance.new("TextLabel")
	feedbackLabel.Name = "FeedbackLabel"
	feedbackLabel.Size = UDim2.new(1, 0, 0, 50)
	feedbackLabel.Position = UDim2.new(0, 0, 0, 100)
	feedbackLabel.BackgroundTransparency = 1
	feedbackLabel.Text = ""
	feedbackLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	feedbackLabel.TextSize = 28
	feedbackLabel.Font = Enum.Font.GothamBold
	feedbackLabel.TextTransparency = 1
	feedbackLabel.TextStrokeTransparency = 1
	feedbackLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	feedbackLabel.Parent = mainFrame

	local uiScale = Instance.new("UIScale")
	uiScale.Parent = mainFrame
	self:scaleForDevice(mainFrame, uiScale)

	self.gui = screenGui
	self.mainFrame = mainFrame
	self.indicator = indicator
	self.timingBar = timingBar
	self.perfectZone = perfectZone
	self.goodZone = goodZone
	self.slashButton = slashButton
	self.slashCounter = slashCounter
	self.speedLabel = speedLabel
	self.feedbackLabel = feedbackLabel
	self.title = title

	slashButton.MouseButton1Click:Connect(function()
		self:onSlash()
	end)

	screenGui.Parent = playerGui
end

function WebCutterHandler:scaleForDevice(frame: Frame, uiScale: UIScale)
	local camera = workspace.CurrentCamera
	local viewportSize = camera.ViewportSize

	local baseWidth = 1920
	local baseHeight = 1080

	local scaleX = viewportSize.X / baseWidth
	local scaleY = viewportSize.Y / baseHeight
	local scale = math.min(scaleX, scaleY)
	scale = math.clamp(scale, 0.5, 1.3)

	uiScale.Scale = scale

	camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		local newViewportSize = camera.ViewportSize
		local newScaleX = newViewportSize.X / baseWidth
		local newScaleY = newViewportSize.Y / baseHeight
		local newScale = math.min(newScaleX, newScaleY)
		newScale = math.clamp(newScale, 0.5, 1.3)
		uiScale.Scale = newScale
	end)
end

--// Minigame Logic
function WebCutterHandler:openMinigame()
	if not self.gui then
		self:createUI()
	end

	self.slashesComplete = 0
	self.indicatorPosition = 0.5
	self.indicatorDirection = 1
	self.currentSpeed = BASE_INDICATOR_SPEED
	self.isMinigameActive = true

	self.slashCounter.Text = "0/" .. SLASHES_REQUIRED
	self.speedLabel.Text = "SPEED: 1.0x"
	self.title.Text = "⚔️ CUT THE WEB! ⚔️"
	self.feedbackLabel.Text = ""
	self.feedbackLabel.TextTransparency = 1
	self.slashButton.Visible = true

	self.gui.Enabled = true
	self:startIndicatorMovement()
end

function WebCutterHandler:startIndicatorMovement()
	if self.updateConnection then return end

	self.updateConnection = RunService.Heartbeat:Connect(function(deltaTime)
		if not self.isMinigameActive then
			if self.updateConnection then
				self.updateConnection:Disconnect()
				self.updateConnection = nil
			end
			return
		end

		self.indicatorPosition = self.indicatorPosition + (self.indicatorDirection * self.currentSpeed * deltaTime)

		if self.indicatorPosition >= 1 then
			self.indicatorPosition = 1
			self.indicatorDirection = -1
		elseif self.indicatorPosition <= 0 then
			self.indicatorPosition = 0
			self.indicatorDirection = 1
		end

		self.indicator.Position = UDim2.new(self.indicatorPosition, 0, 0.5, 0)
	end)
end

function WebCutterHandler:onSlash()
	if not self.isMinigameActive then return end

	local center = 0.5
	local distance = math.abs(self.indicatorPosition - center)

	local hitType = nil
	local feedback = ""
	local feedbackColor = Color3.fromRGB(255, 255, 255)

	if distance <= PERFECT_ZONE_SIZE / 2 then
		hitType = "PERFECT"
		feedback = "⚡ PERFECT! ⚡"
		feedbackColor = Color3.fromRGB(100, 255, 150)
		self.slashesComplete = self.slashesComplete + 1
		self.currentSpeed = self.currentSpeed + SPEED_INCREASE_PER_HIT
	elseif distance <= GOOD_ZONE_SIZE / 2 then
		hitType = "GOOD"
		feedback = "✓ GOOD! ✓"
		feedbackColor = Color3.fromRGB(255, 220, 100)
		self.slashesComplete = self.slashesComplete + 1
		self.currentSpeed = self.currentSpeed + (SPEED_INCREASE_PER_HIT * 0.5)
	else
		hitType = "MISS"
		feedback = "✗ MISS! ✗"
		feedbackColor = Color3.fromRGB(255, 100, 100)
		self.slashesComplete = math.max(0, self.slashesComplete + MISS_PENALTY)
		self.currentSpeed = math.max(BASE_INDICATOR_SPEED, self.currentSpeed - 0.1)
	end

	self:showFeedback(feedback, feedbackColor)
	self:animateSlash(hitType)

	self.slashCounter.Text = self.slashesComplete .. "/" .. SLASHES_REQUIRED
	local speedMultiplier = math.floor((self.currentSpeed / BASE_INDICATOR_SPEED) * 10) / 10
	self.speedLabel.Text = "SPEED: " .. speedMultiplier .. "x"

	if self.slashesComplete >= SLASHES_REQUIRED then
		self:completeMinigame()
	end
end

function WebCutterHandler:showFeedback(text: string, color: Color3)
	self.feedbackLabel.Text = text
	self.feedbackLabel.TextColor3 = color
	self.feedbackLabel.TextTransparency = 0
	self.feedbackLabel.TextStrokeTransparency = 0.5

	local scaleTween = TweenService:Create(self.feedbackLabel, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
		TextSize = 32
	})
	scaleTween:Play()

	task.wait(0.2)

	TweenService:Create(self.feedbackLabel, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
		TextSize = 28
	}):Play()
end

function WebCutterHandler:animateSlash(hitType: string)
	local color = Color3.fromRGB(255, 100, 100)
	local shakeAmount = 5

	if hitType == "PERFECT" then
		color = Color3.fromRGB(100, 255, 150)
		shakeAmount = 15
	elseif hitType == "GOOD" then
		color = Color3.fromRGB(255, 220, 100)
		shakeAmount = 10
	end

	self.slashButton.BackgroundColor3 = color

	for i = 1, 3 do
		local randomX = math.random(-shakeAmount, shakeAmount)
		local randomY = math.random(-shakeAmount, shakeAmount)
		self.mainFrame.Position = UDim2.new(0.5, randomX, 0.5, randomY)
		task.wait(0.02)
	end

	self.mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

	TweenService:Create(self.slashButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0.7, 0, 0, 95)
	}):Play()

	task.wait(0.15)

	TweenService:Create(self.slashButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0.65, 0, 0, 90),
		BackgroundColor3 = Color3.fromRGB(220, 60, 60)
	}):Play()
end

function WebCutterHandler:completeMinigame()
	self.isMinigameActive = false

	self.title.Text = "✅ WEB CUT! ✅"
	self.title.TextColor3 = Color3.fromRGB(100, 255, 150)
	self.slashButton.Visible = false

	local questRemotes = ReplicatedStorage:WaitForChild("QuestRemotes")
	local webCutterUsed = questRemotes:WaitForChild("WebCutterUsed", 5)

	if webCutterUsed then
		webCutterUsed:FireServer()
	end

	self:destroyWeb()

	task.wait(2)
	self:closeMinigame()
	self:cleanup()
end

function WebCutterHandler:closeMinigame()
	if self.gui then
		self.gui.Enabled = false
	end
	self.isMinigameActive = false
end

function WebCutterHandler:destroyWeb()
	if not self.webMesh or not self.webMesh.Parent then return end

	local tween = TweenService:Create(self.webMesh, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 1
	})
	tween:Play()
	tween.Completed:Connect(function()
		if self.webMesh and self.webMesh.Parent then
			self.webMesh:Destroy()
		end
	end)
end

function WebCutterHandler:cleanup()
	self:stopDistanceCheck()
	self:removeProximityPrompt()

	if self.updateConnection then
		self.updateConnection:Disconnect()
		self.updateConnection = nil
	end

	if self.tool then
		self.tool:Destroy()
	end
end

function WebCutterHandler:destroy()
	self:cleanup()
	if self.gui then
		self.gui:Destroy()
	end
end

return WebCutterHandler
