local Jecs = require("@jecs")
local _components = require("@components")
local _noop = require("@std/noop")

local enum = require("@shared/metadata/states/player_movement/enum")
local types = require("@shared/metadata/states/player_movement/types")

local input_map = require("@shared/metadata/input_map")
local state_registry = require("@shared/utils/state_registry")
local movement_transition = state_registry.create_transition("player_movement")

local SUSTAIN_TIME = 0.2
local SUSTAIN_IMPULSE_SCALE = 0.5

return table.freeze({
	on_enter = function(world: Jecs.World, entity: Jecs.Entity, context: types.Context)
		print("Jumping", context)
		local controller_manager = context.controller
		local ground_sensor = context.ground_sensor
		local character = context.character

		local jumpImpulse: Vector3 = Vector3.new(0, 90, 0)
		controller_manager.RootPart:ApplyImpulse(jumpImpulse)
		character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		controller_manager.ActiveController = controller_manager.AirController

		if ground_sensor.HitFrame then
			ground_sensor.SensedPart:ApplyImpulseAtPosition(-jumpImpulse, ground_sensor.HitFrame.Position)
		end

		context._jump_sustain_time = 0
		context._jump_sustain_active = true
	end,

	on_exit = function(world: Jecs.World, entity: Jecs.Entity, context: types.Context)
		context._jump_sustain_active = false
	end,

	update = function(world: Jecs.World, entity: Jecs.Entity, dt: number, context: types.Context)
		if context._jump_sustain_active and context._jump_sustain_time < SUSTAIN_TIME then
			if input_map.jump:down() then
				local sustainImpulse = Vector3.new(0, 120, 0) * SUSTAIN_IMPULSE_SCALE * dt / SUSTAIN_TIME
				context.character.HumanoidRootPart:ApplyImpulse(sustainImpulse)
				context._jump_sustain_time += dt
			else
				context._jump_sustain_active = false
			end
		elseif context.controller.GroundSensor then
			movement_transition(world, entity, context, enum.IDLE)
		end
	end,
})
