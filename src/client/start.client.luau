local ReplicatedStorage = game:GetService("ReplicatedStorage")

local startup = require("@shared/startup")
local systems = {}

local function addSystems(folder: Folder)
	for _, system: ModuleScript in folder:GetChildren() do
		if not system:IsA("ModuleScript") or table.find(systems, require(system) :: any) then
			continue
		end

		table.insert(systems, require(system) :: any)
	end
end

table.insert(systems, require(ReplicatedStorage.client.systems.camera) :: any)
table.insert(systems, require(ReplicatedStorage.client.systems.camera.camera_spring) :: any)
table.insert(systems, require(ReplicatedStorage.client.systems.camera.camera_lean) :: any)

addSystems(ReplicatedStorage.shared.systems)
addSystems(ReplicatedStorage.client.systems)

startup(systems)
