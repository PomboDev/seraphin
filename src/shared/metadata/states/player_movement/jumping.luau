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
		local controller_manager = context.controller
		local character = context.character

		character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		context.character.HumanoidRootPart:ApplyImpulse(Vector3.new(0, 90, 0))
		controller_manager.ActiveController = controller_manager.AirController

		context._jump_sustain_time = 0
		context._jump_sustain_active = true
	end,

	on_exit = function(world: Jecs.World, entity: Jecs.Entity, context: types.Context)
		context._jump_sustain_active = false
	end,

	update = function(world: Jecs.World, entity: Jecs.Entity, context: types.Context, dt: number)
		if context._jump_sustain_active and context._jump_sustain_time < SUSTAIN_TIME then
			if input_map.jump:down() then
				local sustainImpulse = Vector3.new(0, 200, 0) * SUSTAIN_IMPULSE_SCALE * dt / SUSTAIN_TIME
				context.character.HumanoidRootPart:ApplyImpulse(sustainImpulse)
				context._jump_sustain_time += dt
			else
				context._jump_sustain_active = false
			end
		else
			movement_transition(world, entity, context, enum.FALLING)
		end
	end,
})
