local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local startup = require("@shared/startup")
local systems = {}

local function addSystems(folder: Folder)
	for _, system: ModuleScript in folder:GetChildren() do
		if not system:IsA("ModuleScript") then
			continue
		end

		table.insert(systems, require(system) :: any)
	end
end

addSystems(ReplicatedStorage.shared.systems)
addSystems(ServerScriptService.server.systems)

startup(systems)
