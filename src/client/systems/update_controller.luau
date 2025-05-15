local Jecs = require("@jecs")
local PlanckRunService = require("@packages/planck-runservice")

local components = require("@components")
local Phases = PlanckRunService.Phases
local camera = workspace.CurrentCamera

local function update_controller(world: Jecs.World)
	for _id, character in world:query(components.Character):with(components.LocalPlayer) do
		local controller_manager = character.ControllerManager
		local direction = character.Humanoid.MoveDirection

		controller_manager.MovingDirection = direction

		local cameraLookVector = camera.CFrame.LookVector
		controller_manager.FacingDirection = Vector3.new(cameraLookVector.X, 0, cameraLookVector.Z).Unit
	end
end

return {
	system = update_controller,
	phase = Phases.PreSimulation,
}
