local Jecs = require("@jecs")
local components = require("@components")
local noop = require("@std/noop")

local enum = require("@shared/metadata/states/player_movement/enum")
local input_map = require("@shared/metadata/input_map")
local state_registry = require("@shared/utils/state_registry")

local movement_transition = state_registry.create_transition("player_movement")

return table.freeze({
	on_enter = function(world: Jecs.World, entity: Jecs.Entity)
		local character = world:get(entity, components.Character)
		if character == nil then
			return
		end

		local controller_manager = character.ControllerManager
		controller_manager.ActiveController = controller_manager.GroundController
		character.Humanoid:ChangeState(Enum.HumanoidStateType.Running)

		-- Reset movement timers
		world:set(entity, components.MovementTimers, {
			coyote_time = 0,
			jump_buffer = 0,
			jump_cooldown = 0,
		})
	end,

	on_exit = noop,

	update = function(world: Jecs.World, entity: Jecs.Entity, dt: number)
		local character = world:get(entity, components.Character)
		local movement_timers = world:get(entity, components.MovementTimers)
		if character == nil or movement_timers == nil then
			return
		end

		local hit_part = character.HumanoidRootPart.GroundSensor.SensedPart
		local hit_normal = character.HumanoidRootPart.GroundSensor.HitNormal

		movement_timers.coyote_time = 0
		if movement_timers.jump_buffer > 0 then
			movement_timers.jump_buffer = math.max(0, movement_timers.jump_buffer - dt)
		end

		if hit_part and hit_normal and math.acos(hit_normal:Dot(Vector3.new(0, 1, 0))) >= math.rad(45) then
			movement_transition(world, entity, enum.FALLING)
			return
		end

		if character.HumanoidRootPart.GroundSensor.SensedPart == nil then
			movement_timers.coyote_time = 0.2
			movement_transition(world, entity, enum.FALLING)
			return
		end

		if input_map.crouch:down() == false then
			if character.Humanoid.MoveDirection ~= Vector3.zero then
				movement_transition(world, entity, enum.WALKING)
				return
			else
				movement_transition(world, entity, enum.IDLE)
				return
			end
		end

		world:set(entity, components.MovementTimers, movement_timers)
	end,
})
