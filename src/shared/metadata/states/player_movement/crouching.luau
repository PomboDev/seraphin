local Jecs = require("@jecs")
local _components = require("@components")
local noop = require("@std/noop")

local enum = require("@shared/metadata/states/player_movement/enum")
local input_map = require("@shared/metadata/input_map")
local state_registry = require("@shared/utils/state_registry")
local types = require("@shared/metadata/states/player_movement/types")

local movement_transition = state_registry.create_transition("player_movement")

return table.freeze({
	on_enter = function(_world: Jecs.World, _entity: Jecs.Entity, context: types.Context)
		local controller_manager = context.controller
		controller_manager.ActiveController = controller_manager.GroundController
		context.character.Humanoid:ChangeState(Enum.HumanoidStateType.Running)

		context.coyote_time = 0
		context.jump_buffer = 0
	end,

	on_exit = noop,

	update = function(world: Jecs.World, entity: Jecs.Entity, context: types.Context, dt: number)
		local hit_part = context.ground_sensor.SensedPart
		local hit_normal = context.ground_sensor.HitNormal

		context.coyote_time = 0
		if context.jump_buffer then
			context.jump_buffer = math.max(0, context.jump_buffer - dt)
		end

		if hit_part and math.acos(hit_normal:Dot(Vector3.new(0, 1, 0))) >= math.rad(45) then
			movement_transition(world, entity, context, enum.FALLING)
			return
		end

		if context.ground_sensor.SensedPart == nil then
			context.coyote_time = 0.2
			movement_transition(world, entity, context, enum.FALLING)
			return
		end

		if input_map.crouch.down() == false then
			if context.humanoid.MoveDirection ~= Vector3.zero then
				movement_transition(world, entity, context, enum.WALKING)
				return
			else
				movement_transition(world, entity, context, enum.IDLE)
				return
			end
		end
	end,
})
