local Jecs = require("@jecs")
local PlanckRunService = require("@packages/planck-runservice")

local components = require("@components")
local Phases = PlanckRunService.Phases

local function update_controller(world: Jecs.World)
	for _id, character in world:query(components.Character):with(components.LocalPlayer) do
		local controller_manager = character.ControllerManager
		local direction = character.Humanoid.MoveDirection

		controller_manager.MovingDirection = direction

		if direction.Magnitude > 0 then
			controller_manager.FacingDirection = direction
		else
			controller_manager.FacingDirection = character.HumanoidRootPart.CFrame.LookVector
		end
	end
end

return {
	system = update_controller,
	phase = Phases.PreSimulation,
}
