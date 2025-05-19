local Jecs = require("@jecs")
local PlanckRunService = require("@packages/planck-runservice")

local components = require("@components")
local Phases = PlanckRunService.Phases
local camera = workspace.CurrentCamera
local grounded_accumulator = 0
local base_speed = 24

local function update_controller(world: Jecs.World)
	for _id, character in world:query(components.Character):with(components.LocalPlayer) do
		local controller_manager = character.ControllerManager
		local root_part = character.HumanoidRootPart

		local cameraLookVector = camera.CFrame.LookVector
		local camForward = Vector3.new(cameraLookVector.X, 0, cameraLookVector.Z).Unit

		local override_speed = math.floor((root_part.AssemblyLinearVelocity * Vector3.new(1, 0, 1)).Magnitude)
		if override_speed >= base_speed then
			controller_manager.BaseMoveSpeed = override_speed
			if controller_manager.ActiveController == controller_manager.GroundController then
				grounded_accumulator += 0.025
				controller_manager.BaseMoveSpeed =
					math.max(controller_manager.BaseMoveSpeed * math.min(1 - grounded_accumulator, 0.1), base_speed)
				root_part.AssemblyLinearVelocity *= math.min(1 - grounded_accumulator, 0.1)
			else
				grounded_accumulator = 0
			end
		else
			controller_manager.BaseMoveSpeed = base_speed
		end

		controller_manager.MovingDirection = character.Humanoid.MoveDirection
		controller_manager.FacingDirection = camForward
	end
end

return {
	system = update_controller,
	phase = Phases.PreSimulation,
}
