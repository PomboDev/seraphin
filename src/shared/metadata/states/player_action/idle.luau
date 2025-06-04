local Jecs = require("@jecs")

local input_map = require("@shared/metadata/input_map")
local state_registry = require("@shared/utils/state_registry")

local enum = require("@shared/metadata/states/player_action/enum")

local action_transition = state_registry.create_transition("player_action")

return table.freeze({
	on_enter = function(_world: Jecs.World, _entity: Jecs.Entity) end,

	on_exit = function() end,

	update = function(world: Jecs.World, entity: Jecs.Entity, _dt: number)
		if input_map.shoot:pressed() then
			action_transition(world, entity, enum.SHOOTING)
		end
	end,
})
