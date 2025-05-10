local Jecs = require("@jecs")
local _components = require("@components")
local _noop = require("@std/noop")

local enum = require("@shared/metadata/states/player_movement/enum")
local state_registry = require("@shared/utils/state_registry")

local movement_transition = state_registry.create_transition("player_movement")
local jump_duration = 0.5

return table.freeze({
	on_enter = function(world: Jecs.World, entity: Jecs.Entity, context: any?)
		print("Jumping state entered")
		context.jump_start_time = os.clock()
	end,

	on_exit = function(world: Jecs.World, entity: Jecs.Entity, context: any?)
		print("Jumping state exited")
		context.jump_start_time = nil
	end,

	update = function(world: Jecs.World, entity: Jecs.Entity, dt: number, context: any?)
		if os.clock() - context.jump_start_time >= jump_duration then
			print("Transitioning to idle")
			movement_transition(world, entity, context, enum.IDLE)
		end
	end,
})
