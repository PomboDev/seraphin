local Jecs = require("@jecs")
local _components = require("@components")
local input_map = require(script.Parent.Parent.Parent.input_map)
local noop = require("@std/noop")

local enum = require("@shared/metadata/states/player_movement/enum")
local state_registry = require("@shared/utils/state_registry")
local types = require("@shared/metadata/states/player_movement/types")

local SLIDE_BOOST = 32 -- initial speed boost
local SLIDE_FRICTION = 48 -- higher = stops faster
local SLIDE_MIN_SPEED = 4 -- below this, go to crouch

local movement_transition = state_registry.create_transition("player_movement")

return table.freeze({
	on_enter = function(_world: Jecs.World, _entity: Jecs.Entity, context: types.Context)
		local controller_manager = context.controller
		local root_part = context.character.HumanoidRootPart

		controller_manager.ActiveController = controller_manager.SlidingController
		context.character.Humanoid:ChangeState(Enum.HumanoidStateType.Running)

		local move_dir = context.humanoid.MoveDirection
		root_part:ApplyImpulse(move_dir * SLIDE_BOOST)

		context._slide_timer = 0
		context._sliding = true
	end,

	on_exit = function(_world, _entity, context)
		context._sliding = false
	end,

	update = function(world: Jecs.World, entity: Jecs.Entity, context: types.Context, dt: number)
		local root_part = context.character.HumanoidRootPart
		local velocity = root_part.AssemblyLinearVelocity
		local speed = velocity.Magnitude

		-- if speed > 0 then
		-- 	local friction = math.min(SLIDE_FRICTION * dt, 1)
		-- 	local new_horizontal = horizontal * (1 - friction)
		-- 	root_part.AssemblyLinearVelocity = Vector3.new(new_horizontal.X, velocity.Y, new_horizontal.Z)
		-- end

		if speed < SLIDE_MIN_SPEED or context.ground_sensor.SensedPart == nil and input_map.crouch:down() then
			movement_transition(world, entity, context, enum.CROUCHING)
			return
		end

		if input_map.jump:pressed() then
			movement_transition(world, entity, context, enum.JUMPING)
			print("Slide Jump")
			return
		end

		if input_map.crouch:released() then
			if context.humanoid.MoveDirection ~= Vector3.zero then
				movement_transition(world, entity, context, enum.WALKING)
			else
				movement_transition(world, entity, context, enum.IDLE)
			end
			return
		end
	end,
})
