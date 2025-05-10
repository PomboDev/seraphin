local Players = game:GetService("Players")

local Jecs = require("@jecs")
local Planck = require("@packages/planck")

local components = require("@components")
local state_machine_utils = require("@shared/utils/state_machine_utils")

local player_movement_enum = require("@shared/metadata/states/player_movement/enum")
local player_movement_states = require("@shared/metadata/states/player_movement")

local function initialize_client(world: Jecs.World)
	world:set(components.LocalPlayer, components.LocalPlayer, Players.LocalPlayer)

	for id in world:query(components.LocalPlayer):without(components.StateMachines) do
		state_machine_utils.create_state_machine(world, id, player_movement_states, player_movement_enum.IDLE)
	end
end

return {
	system = initialize_client,
	phase = Planck.Phase.PreStartup,
}
