local Players = game:GetService("Players")
local Planck = require("@packages/planck")

local Jecs = require("@jecs")
local components = require("@components")

local onEvent = Planck.onEvent
local event_fired, collect = onEvent(Players, "PlayerRemoving")

local function player_removed(world: Jecs.World)
	for _, player_leaving in (collect() :: any) :: { [any]: Player } do
		for id, player in world:query(components.Player) do
			if player == player_leaving then
				world:delete(id)
				print(`Player {player_leaving.Name} entity destroyed: {id}`)
			end
		end
	end
end

return {
	system = player_removed,
	runConditions = { event_fired },
}
