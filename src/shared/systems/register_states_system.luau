local RunService = game:GetService("RunService")
local Jecs = require("@jecs")

local Planck = require("@packages/planck")
local player_movement_states = require("@shared/metadata/states/player_movement")
local state_machine_utils = require("@shared/utils/state_machine_utils")

local function register_states_system(_world: Jecs.World)
	if RunService:IsClient() then
		state_machine_utils.register_state_group("player_movement", player_movement_states)
	end
end

return {
	system = register_states_system,
	phase = Planck.Phase.PreStartup,
}
