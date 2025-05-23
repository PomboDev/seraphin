local Jecs = require("@jecs")
local _components = require("@components")
local _noop = require("@std/noop")

local enum = require("@shared/metadata/states/player_movement/enum")
local types = require("@shared/metadata/states/player_movement/types")

local input_map = require("@shared/metadata/input_map")
local state_registry = require("@shared/utils/state_registry")
local movement_transition = state_registry.create_transition("player_movement")
local camera = workspace.CurrentCamera

local SUSTAIN_TIME = 0.2
local SUSTAIN_IMPULSE_SCALE = 0.5

return table.freeze({
	on_enter = function(world: Jecs.World, entity: Jecs.Entity, context: types.Context)
		local controller_manager = context.controller
		local character = context.character
		local root_part = character.HumanoidRootPart

		local velocity = root_part.AssemblyLinearVelocity
		local velocity_horizontal = velocity * Vector3.new(1, 0, 1)

		if velocity.Y < 0 then
			root_part.AssemblyLinearVelocity = velocity_horizontal
		end

		if math.floor(controller_manager.BaseMoveSpeed) > 24 then
			local camForward = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
			local redirecting_impulse = camForward * velocity.Magnitude
			root_part.AssemblyLinearVelocity = redirecting_impulse
		end

		character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		root_part:ApplyImpulse(Vector3.new(0, 90, 0))
		controller_manager.ActiveController = controller_manager.AirController

		context._jump_sustain_time = 0
		context._jump_sustain_active = true

		context.coyote_time = 0
		context.jump_buffer = 0
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
			return
		end
	end,
})
