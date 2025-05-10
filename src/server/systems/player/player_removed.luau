local Players = game:GetService("Players")
local Planck = require("@packages/planck")

local Jecs = require("@jecs")
local components = require("@components")

local onEvent = Planck.onEvent
local event_fired, collect = onEvent(Players, "PlayerRemoving")

local function player_removed(world: Jecs.World)
	for _, player_removed in collect() do
		for id, player_value in world:query(components.Player) do
			if player_value == player_removed then
				world:delete(id)
				print(`Player {player_removed.Name} entity destroyed: {id}`)
			end
		end
	end
end

return {
	system = player_removed,
	runConditions = { event_fired },
}
