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
	end,

	on_exit = noop,

	update = function(world: Jecs.World, entity: Jecs.Entity, context: types.Context)
		if context.humanoid.MoveDirection ~= Vector3.zero then
			movement_transition(world, entity, context, enum.WALKING)
		end

		if input_map.jump:pressed() then
			movement_transition(world, entity, context, enum.JUMPING)
		end

		if context.ground_sensor.SensedPart == nil then
			movement_transition(world, entity, context, enum.FALLING)
		end
	end,
})
