--// Modules
local DialogModule = require(script:WaitForChild("DialogModule"))
local Types = script.DialogModule.Types

--// Initialize all NPCs
for _, npcTypeModule in ipairs(Types:GetChildren()) do
	if npcTypeModule:IsA("ModuleScript") then
		local success, npcType = pcall(require, npcTypeModule)
		if success and npcType.init then
			task.spawn(function()
				local initSuccess, result = pcall(npcType.init)
				if initSuccess then
					print("Initialized NPC:", npcTypeModule.Name)
				else
					warn("Failed to initialize NPC:", npcTypeModule.Name, result)
				end
			end)
		else
			warn("NPC module missing init function:", npcTypeModule.Name)
		end
	end
end
