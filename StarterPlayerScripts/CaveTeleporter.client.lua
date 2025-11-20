--[[
	Cave Teleporter
	Handles teleportation into and out of the cave
]]

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--// Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local questRemotes = ReplicatedStorage:WaitForChild("QuestRemotes", 10)
local hasCaveAccess = false

--// Listen for ClearWeb completion (cave access granted)
local clearWebCompleteRemote = ReplicatedStorage:WaitForChild("QuestRemotes"):WaitForChild("QuestComplete", 10)
if clearWebCompleteRemote then
	clearWebCompleteRemote.OnClientEvent:Connect(function(questName)
		if questName == "ClearWeb" then
			hasCaveAccess = true
			print("✅ Cave access granted!")
		end
	end)
end

--// Get teleport parts
local function getCaveEntrance()
	local success, result = pcall(function()
		return workspace:WaitForChild("Halloween2025", 10)
			:WaitForChild("Quests", 10)
			:WaitForChild("Builds", 10)
			:WaitForChild("Cave", 10)
			:WaitForChild("Important", 10)
			:WaitForChild("Primary", 10)
	end)
	return success and result or nil
end

local function getCaveTPPart()
	local success, result = pcall(function()
		return workspace:WaitForChild("Halloween2025", 10)
			:WaitForChild("Quests", 10)
			:WaitForChild("Builds", 10)
			:WaitForChild("BlackBox", 10)
			:WaitForChild("Important", 10)
			:WaitForChild("TPpart", 10)
	end)
	return success and result or nil
end

local function getLobbyTPPart()
	local success, result = pcall(function()
		return workspace:WaitForChild("TPpart2", 10)
	end)
	return success and result or nil
end

--// Teleport with fade effect
local function teleportPlayer(targetPart)
	local playerGui = player:WaitForChild("PlayerGui")

	-- Create fade screen
	local fadeScreen = Instance.new("ScreenGui")
	fadeScreen.Name = "TeleportFade"
	fadeScreen.IgnoreGuiInset = true
	fadeScreen.DisplayOrder = 999

	local fadeFrame = Instance.new("Frame")
	fadeFrame.Size = UDim2.new(1, 0, 1, 0)
	fadeFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	fadeFrame.BackgroundTransparency = 1
	fadeFrame.BorderSizePixel = 0
	fadeFrame.Parent = fadeScreen

	fadeScreen.Parent = playerGui

	-- Fade out
	local fadeOut = TweenService:Create(fadeFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
		BackgroundTransparency = 0
	})
	fadeOut:Play()
	fadeOut.Completed:Wait()

	-- Teleport
	if character and character:FindFirstChild("HumanoidRootPart") then
		character.HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
	end

	task.wait(0.3)

	-- Fade in
	local fadeIn = TweenService:Create(fadeFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
		BackgroundTransparency = 1
	})
	fadeIn:Play()
	fadeIn.Completed:Wait()

	fadeScreen:Destroy()
end

--// Setup cave entrance
local caveEntrance = getCaveEntrance()
if caveEntrance then
	local debounce = false

	caveEntrance.Touched:Connect(function(hit)
		if debounce then return end

		local touchedCharacter = hit.Parent
		if touchedCharacter and touchedCharacter:FindFirstChild("Humanoid") then
			local touchedPlayer = Players:GetPlayerFromCharacter(touchedCharacter)

			if touchedPlayer == player then
				if not hasCaveAccess then
					-- Show message that they need to complete the quest
					local playerGui = player:WaitForChild("PlayerGui")
					local messageGui = playerGui:FindFirstChild("MessageGui")
					if messageGui then
						local messageLabel = messageGui:FindFirstChild("Message")
						if messageLabel and messageLabel:IsA("TextLabel") then
							messageLabel.Text = "🔒 Complete the spider web quest to enter the cave!"
							messageLabel.Visible = true
							task.wait(3)
							messageLabel.Visible = false
						end
					end
					return
				end

				debounce = true

				local caveTp = getCaveTPPart()
				if caveTp then
					teleportPlayer(caveTp)

					-- Fire objective 1 completion (entering cave)
					local enterCaveRemote = questRemotes:FindFirstChild("EnterCave")
					if enterCaveRemote then
						enterCaveRemote:FireServer()
					end
				end

				task.wait(2)
				debounce = false
			end
		end
	end)

	print("✅ Cave entrance teleporter initialized")
end

--// Setup lobby return
local lobbyTp = getLobbyTPPart()
if lobbyTp then
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Return to Lobby"
	prompt.ObjectText = "Exit Cave"
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = lobbyTp

	prompt.Triggered:Connect(function(playerWhoTriggered)
		if playerWhoTriggered == player then
			teleportPlayer(lobbyTp)
		end
	end)

	print("✅ Lobby return teleporter initialized")
end

--// Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)
