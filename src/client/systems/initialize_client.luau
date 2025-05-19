local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Jecs = require("@jecs")
local Planck = require("@packages/planck")

local components = require("@components")
local state_machine_utils = require("@shared/utils/state_machine_utils")

local player_action_enum = require("@shared/metadata/states/player_action/enum")
local player_action_states = require("@shared/metadata/states/player_action")
local player_movement_enum = require("@shared/metadata/states/player_movement/enum")
local player_movement_states = require("@shared/metadata/states/player_movement")

local function initialize_client(world: Jecs.World)
	local camera = workspace.CurrentCamera
	world:set(components.LocalPlayer, components.LocalPlayer, Players.LocalPlayer)

	task.defer(function()
		for id in world:query(components.LocalPlayer):without(components.StateMachines) do
			local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() :: any
			world:set(components.LocalPlayer, components.Character, character)

			state_machine_utils.create_state_machine(world, id, player_movement_states, player_movement_enum.IDLE, {
				controller = character.ControllerManager,
				character = character,
				humanoid = character.Humanoid,
				root_part = character.HumanoidRootPart,
				climb_sensor = character.HumanoidRootPart.ClimbSensor,
				ground_sensor = character.HumanoidRootPart.GroundSensor,
			})

			state_machine_utils.create_state_machine(world, id, player_action_states, player_action_enum.IDLE, {
				camera = camera,
				character = character,
			})
		end
	end)
end

return {
	system = initialize_client,
	phase = Planck.Phase.PreStartup,
}
