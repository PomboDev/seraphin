local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Jecs = require("@jecs")
local PlanckRunService = require("@packages/planck-runservice")

local components = require("@components")
UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

local function initialize_client(world: Jecs.World)
	for id, player in world:query(components.Player):without(components.LocalPlayer) do
		if player == Players.LocalPlayer then
			local camera = workspace.CurrentCamera
			world:set(id, components.LocalPlayer, player)
			world:set(id, components.Camera, camera)
		end
	end
end

return {
	system = initialize_client,
	phase = PlanckRunService.Phases.PostSimulation,
}
