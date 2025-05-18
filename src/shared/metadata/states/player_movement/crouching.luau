local Jecs = require("@jecs")
local _components = require("@components")
local noop = require("@std/noop")

local enum = require("@shared/metadata/states/player_movement/enum")
local types = require("@shared/metadata/states/player_movement/types")

local input_map = require("@shared/metadata/input_map")
local state_registry = require("@shared/utils/state_registry")

local movement_transition = state_registry.create_transition("player_movement")

local SLIDE_ANGLE_THRESHOLD = math.rad(25) -- Minimum angle to start sliding

return table.freeze({
	on_enter = function(world: Jecs.World, entity: Jecs.Entity, context: types.Context)
		context.controller.ActiveController = context.controller.CrouchController
		context.character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	end,

	on_exit = noop,

	update = function(world: Jecs.World, entity: Jecs.Entity, context: types.Context)
		local move_direction = context.humanoid.MoveDirection
		local is_falling = context.character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall
		local ground_sensor = context.ground_sensor
		local hit_normal = ground_sensor.HitNormal or Vector3.new(0, 1, 0)

		local angle = math.acos(hit_normal:Dot(Vector3.new(0, 1, 0)))
		local is_sloped = angle > SLIDE_ANGLE_THRESHOLD

		if input_map.crouch:down() then
			if (move_direction.Magnitude > 0 or is_falling) and is_sloped then
				movement_transition(world, entity, context, enum.SLIDING)
			end
		else
			if is_falling then
				movement_transition(world, entity, context, enum.FALLING)
			elseif move_direction.Magnitude == 0 then
				movement_transition(world, entity, context, enum.IDLE)
			else
				movement_transition(world, entity, context, enum.WALKING)
			end
		end
	end,
})
