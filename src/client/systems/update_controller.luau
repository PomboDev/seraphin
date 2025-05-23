local Jecs = require("@jecs")
local PlanckRunService = require("@packages/planck-runservice")
local components = require("@components")

local state_machine_utils = require("@shared/utils/state_machine_utils")

local player_action_enum = require("@shared/metadata/states/player_action/enum")
local player_action_states = require("@shared/metadata/states/player_action")
local player_movement_enum = require("@shared/metadata/states/player_movement/enum")
local player_movement_states = require("@shared/metadata/states/player_movement")

local Phases = PlanckRunService.Phases

local grounded_accumulator = 0
local base_speed = 24

local slower_velocity_states = { "crouching", "aiming" }
local override_velocity_states = { "idle", "walking", "sliding", "jumping", "falling" }

local function update_controller(world: Jecs.World)
	for id, player, camera in world:query(components.LocalPlayer, components.Camera):without(components.StateMachines) do
		local character = (player.Character :: any) :: components.Character
		if character == nil then
			continue
		end

		camera.CameraType = Enum.CameraType.Scriptable
		world:set(id, components.Character, character)

		state_machine_utils.create_state_machine(world, id, player_movement_states, player_movement_enum.IDLE, {
			controller = character.ControllerManager,
			character = character,
			humanoid = character.Humanoid,
			root_part = character.HumanoidRootPart,
			climb_sensor = character.HumanoidRootPart.ClimbSensor,
			ground_sensor = character.HumanoidRootPart.GroundSensor,
		})

		state_machine_utils.create_state_machine(world, id, player_action_states, player_action_enum.IDLE, {
			camera = camera,
			character = character,
		})
	end

	for _id, camera, character, state_machines in
		world:query(components.Camera, components.Character, components.StateMachines)
	do
		local player_movement_state_machine = state_machines[player_movement_states :: any]
		local player_action_state_machine = state_machines[player_action_states :: any]

		local controller_manager = character.ControllerManager
		local move_dir = character.Humanoid.MoveDirection
		local root_part = character.HumanoidRootPart

		local cameraLookVector = camera.CFrame.LookVector
		local camForward = Vector3.new(cameraLookVector.X, 0, cameraLookVector.Z).Unit

		if table.find(override_velocity_states, player_movement_state_machine.current) then
			local override_speed = math.floor((root_part.AssemblyLinearVelocity * Vector3.new(1, 0, 1)).Magnitude)
			if override_speed >= base_speed + 1 then
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
		elseif
			table.find(slower_velocity_states, player_movement_state_machine.current)
			or table.find(slower_velocity_states, player_action_state_machine.current)
		then
			controller_manager.BaseMoveSpeed = base_speed * 0.5
		else
			controller_manager.BaseMoveSpeed = base_speed
		end

		controller_manager.MovingDirection = move_dir
		controller_manager.FacingDirection = camForward
	end
end

return {
	system = update_controller,
	phase = Phases.PreSimulation,
}
