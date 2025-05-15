local Jecs = require("@jecs")
local _components = require("@components")
local noop = require("@std/noop")

local input_map = require("@shared/metadata/input_map")
local state_registry = require("@shared/utils/state_registry")

local enum = require("@shared/metadata/states/player_action/enum")
local types = require("@shared/metadata/states/player_action/types")

local action_transition = state_registry.create_transition("player_action")

return table.freeze({
	on_enter = function(world: Jecs.World, entity: Jecs.Entity, context: types.Context) end,

	on_exit = noop,

	update = function(world: Jecs.World, entity: Jecs.Entity, context: types.Context)
		if input_map.shoot:pressed() then
			action_transition(world, entity, context, enum.SHOOTING)
		end
	end,
})
