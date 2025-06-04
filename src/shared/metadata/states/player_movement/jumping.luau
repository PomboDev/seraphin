local Jecs = require("@jecs")
local components = require("@components")

local enum = require("@shared/metadata/states/player_movement/enum")
local input_map = require("@shared/metadata/input_map")
local state_registry = require("@shared/utils/state_registry")
local movement_transition = state_registry.create_transition("player_movement")
local camera = workspace.CurrentCamera

local SUSTAIN_TIME = 0.2
local SUSTAIN_IMPULSE_SCALE = 0.5

return table.freeze({
	on_enter = function(world: Jecs.World, entity: Jecs.Entity)
		local character = world:get(entity, components.Character)
		local movement_timers = world:get(entity, components.MovementTimers)
		local jump_state = world:get(entity, components.JumpState)
		if character == nil or movement_timers == nil or not jump_state then
			return
		end

		local controller_manager = character.ControllerManager
		local root_part = character.HumanoidRootPart

		local velocity = root_part.AssemblyLinearVelocity
		local velocity_horizontal = velocity * Vector3.new(1, 0, 1)

		if velocity.Y < 0 then
			root_part.AssemblyLinearVelocity = velocity_horizontal
		end

		if math.floor(controller_manager.BaseMoveSpeed) > 24 then
			local camForward = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
			local redirecting_impulse = camForward * velocity.Magnitude
			root_part.AssemblyLinearVelocity = redirecting_impulse
		end

		character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		root_part:ApplyImpulse(Vector3.new(0, jump_state.jump_force, 0))
		controller_manager.ActiveController = controller_manager.AirController

		jump_state.sustain_time = 0
		jump_state.sustain_active = true

		movement_timers.coyote_time = 0
		movement_timers.jump_buffer = 0

		world:set(entity, components.JumpState, jump_state)
		world:set(entity, components.MovementTimers, movement_timers)
	end,

	on_exit = function(world: Jecs.World, entity: Jecs.Entity)
		local jump_state = world:get(entity, components.JumpState)
		if not jump_state then
			return
		end

		jump_state.sustain_active = false
		world:set(entity, components.JumpState, jump_state)
	end,

	update = function(world: Jecs.World, entity: Jecs.Entity, dt: number)
		local character = world:get(entity, components.Character)
		local jump_state = world:get(entity, components.JumpState)
		if character == nil or not jump_state then
			return
		end

		if jump_state.sustain_active and jump_state.sustain_time < SUSTAIN_TIME then
			if input_map.jump:down() then
				local sustainImpulse = Vector3.new(0, 200, 0) * SUSTAIN_IMPULSE_SCALE * dt / SUSTAIN_TIME
				character.HumanoidRootPart:ApplyImpulse(sustainImpulse)
				jump_state.sustain_time += dt
				world:set(entity, components.JumpState, jump_state)
			else
				local updated_jump_state = jump_state :: components.JumpState
				updated_jump_state.sustain_active = false
				world:set(entity, components.JumpState, updated_jump_state)
			end
		else
			movement_transition(world, entity, enum.FALLING)
			return
		end
	end,
})
