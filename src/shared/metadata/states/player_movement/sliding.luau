local Jecs = require("@jecs")
local components = require("@components")
local input_map = require(script.Parent.Parent.Parent.input_map)

local enum = require("@shared/metadata/states/player_movement/enum")
local state_registry = require("@shared/utils/state_registry")

local SLIDE_BOOST = 32 -- initial speed boost
local SLIDE_MIN_SPEED = 4 -- below this, go to crouch

local movement_transition = state_registry.create_transition("player_movement")

return table.freeze({
	on_enter = function(world: Jecs.World, entity: Jecs.Entity)
		local character = world:get(entity, components.Character)
		local slide_state = world:get(entity, components.SlideState)
		if character == nil or not slide_state then
			return
		end

		local controller_manager = character.ControllerManager
		local root_part = character.HumanoidRootPart

		controller_manager.ActiveController = controller_manager.SlidingController
		character.Humanoid:ChangeState(Enum.HumanoidStateType.Running)

		local move_dir = character.Humanoid.MoveDirection
		root_part:ApplyImpulse(move_dir * SLIDE_BOOST)

		slide_state.timer = 0
		slide_state.sliding = true
		world:set(entity, components.SlideState, slide_state)
	end,

	on_exit = function(world: Jecs.World, entity: Jecs.Entity)
		local slide_state = world:get(entity, components.SlideState)
		if not slide_state then
			return
		end

		slide_state.sliding = false
		world:set(entity, components.SlideState, slide_state)
	end,

	update = function(world: Jecs.World, entity: Jecs.Entity, dt: number)
		local character = world:get(entity, components.Character)
		local slide_state = world:get(entity, components.SlideState)
		if character == nil or not slide_state then
			return
		end

		local root_part = character.HumanoidRootPart
		local velocity = root_part.AssemblyLinearVelocity
		local speed = velocity.Magnitude

		slide_state.timer += dt

		if
			speed < SLIDE_MIN_SPEED
			or character.HumanoidRootPart.GroundSensor.SensedPart == nil and input_map.crouch:down()
		then
			movement_transition(world, entity, enum.CROUCHING)
			return
		end

		if input_map.jump:pressed() then
			movement_transition(world, entity, enum.JUMPING)
			print("Slide Jump")
			return
		end

		if input_map.crouch:released() then
			if character.Humanoid.MoveDirection ~= Vector3.zero then
				movement_transition(world, entity, enum.WALKING)
			else
				movement_transition(world, entity, enum.IDLE)
			end
			return
		end

		world:set(entity, components.SlideState, slide_state)
	end,
})
