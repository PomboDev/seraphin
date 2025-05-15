local Jecs = require("@jecs")
local _components = require("@components")
local noop = require("@std/noop")

local enum = require("@shared/metadata/states/player_movement/enum")
local types = require("@shared/metadata/states/player_movement/types")

local input_map = require("@shared/metadata/input_map")
local state_registry = require("@shared/utils/state_registry")

local movement_transition = state_registry.create_transition("player_movement")

return table.freeze({
	on_enter = function(world: Jecs.World, entity: Jecs.Entity, context: types.Context)
		context.controller.ActiveController = context.controller.AirController
		context.character.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	end,

	on_exit = noop,

	update = function(world: Jecs.World, entity: Jecs.Entity, context: types.Context)
		local sensed_part = context.ground_sensor.SensedPart
		local move_direction = context.humanoid.MoveDirection

		if sensed_part then
			if move_direction == Vector3.zero then
				movement_transition(world, entity, context, enum.IDLE)
				context.character.HumanoidRootPart.Velocity *= Vector3.new(1, 0, 1)
			else
				movement_transition(world, entity, context, enum.WALKING)
				context.character.HumanoidRootPart.Velocity *= Vector3.new(1, 0, 1)
			end
		end
	end,
})
