local Jecs = require("@jecs")
local _components = require("@components")
local noop = require("@std/noop")

local enum = require("@shared/metadata/states/player_movement/enum")
local types = require("@shared/metadata/states/player_movement/types")

local input_map = require("@shared/metadata/input_map")
local state_registry = require("@shared/utils/state_registry")

local movement_transition = state_registry.create_transition("player_movement")

local SLIDE_FRICTION = 0.96
local SLIDE_ACCEL = 2.5
local SLIDE_DECEL = 1.5
local MIN_SLIDE_SPEED = 4
local EXIT_ANGLE_THRESHOLD = math.rad(15)

return table.freeze({
	on_enter = function(world: Jecs.World, entity: Jecs.Entity, context: types.Context)
		context.controller.ActiveController = context.controller.SlideController
		context.character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	end,

	on_exit = noop,

	update = function(world: Jecs.World, entity: Jecs.Entity, context: types.Context)
		local humanoid = context.character.Humanoid
		local hrp = context.character.HumanoidRootPart
		local ground_sensor = context.ground_sensor
		local hit_normal = ground_sensor.HitNormal or Vector3.new(0, 1, 0)
		local velocity = hrp.Velocity
		local input = context.input

		-- Calculate slide direction and angle
		local slide_dir = (Vector3.new(hit_normal.X, 0, hit_normal.Z)).Unit
		local angle = math.acos(hit_normal:Dot(Vector3.new(0, 1, 0)))

		-- Project velocity onto the ground plane
		local flat_velocity = Vector3.new(velocity.X, 0, velocity.Z)
		local speed = flat_velocity.Magnitude

		-- Adjust speed based on slope
		if angle > 0 then
			local slope_factor = math.sin(angle)
			if hit_normal.Y < 1 then
				flat_velocity += slide_dir * SLIDE_ACCEL * slope_factor
			end
		end

		-- Apply friction or deceleration
		if math.abs(hit_normal.Y) > math.cos(EXIT_ANGLE_THRESHOLD) then
			flat_velocity *= SLIDE_FRICTION
		else
			flat_velocity -= slide_dir * SLIDE_DECEL * (1 - hit_normal.Y)
		end

		-- Clamp minimum speed
		if flat_velocity.Magnitude < MIN_SLIDE_SPEED then
			flat_velocity = flat_velocity.Unit * MIN_SLIDE_SPEED
		end

		-- Set new velocity
		hrp.Velocity = Vector3.new(flat_velocity.X, velocity.Y, flat_velocity.Z)

		-- Exit slide if crouch released or not sloped
		if not input[input_map.CROUCH] or angle < EXIT_ANGLE_THRESHOLD then
			if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
				movement_transition(world, entity, context, enum.FALLING)
			elseif context.humanoid.MoveDirection.Magnitude == 0 then
				movement_transition(world, entity, context, enum.IDLE)
			else
				movement_transition(world, entity, context, enum.WALKING)
			end
		end
	end,
})
