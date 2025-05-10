local Players = game:GetService("Players")
local Planck = require("@packages/planck")

local Jecs = require("@jecs")
local components = require("@components")

local onEvent = Planck.onEvent
local event_fired, collect = onEvent(Players, "PlayerAdded")

local function player_added(world: Jecs.World)
	for _, player in collect() do
		local player_entity = world:entity()
		world:set(player_entity, components.Player, player)
		print(`Player {player.Name} entity created: {player_entity}`)
	end
end

return {
	system = player_added,
	runConditions = { event_fired },
}
