local Jecs = require("@jecs")
local _components = require("@components")
local noop = require("@std/noop")

local enum = require("@shared/metadata/states/player_movement/enum")
local types = require("@shared/metadata/states/player_movement/types")

local input_map = require("@shared/metadata/input_map")
local state_registry = require("@shared/utils/state_registry")

local movement_transition = state_registry.create_transition("player_movement")

return table.freeze({
	on_enter = function(_world: Jecs.World, _entity: Jecs.Entity, context: types.Context)
		context.controller.ActiveController = context.controller.GroundController
		context.character.Humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end,

	on_exit = noop,

	update = function(world: Jecs.World, entity: Jecs.Entity, context: types.Context)
		local hit_part = context.ground_sensor.SensedPart
		local hit_normal = context.ground_sensor.HitNormal

		if hit_part and math.acos(hit_normal:Dot(Vector3.new(0, 1, 0))) >= math.rad(45) then
			movement_transition(world, entity, context, enum.FALLING)
			return
		end

		if context.humanoid.MoveDirection == Vector3.zero then
			movement_transition(world, entity, context, enum.IDLE)
			return
		end

		if input_map.jump:pressed() then
			movement_transition(world, entity, context, enum.JUMPING)
			return
		end

		if context.ground_sensor.SensedPart == nil then
			movement_transition(world, entity, context, enum.FALLING)
			return
		end
	end,
})
