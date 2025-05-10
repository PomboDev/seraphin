local Jecs = require("@jecs")
local _components = require("@components")
local noop = require("@std/noop")

local enum = require("@shared/metadata/states/player_movement/enum")
local input_map = require("@shared/metadata/input_map")
local state_registry = require("@shared/utils/state_registry")

local movement_transition = state_registry.create_transition("player_movement")

return table.freeze({
	on_enter = function(world: Jecs.World, entity: Jecs.Entity, context: any?)
		print("Idle state entered")
	end,

	on_exit = noop,

	update = function(world: Jecs.World, entity: Jecs.Entity, dt: number, context: any?)
		if input_map.jump:pressed() then
			print("Transitioning to jump")
			movement_transition(world, entity, context, enum.JUMPING)
		end
	end,
})
