local Jecs = require("@jecs")
local PlanckRunService = require("@packages/planck-runservice")

local Phases = PlanckRunService.Phases
local character_utils = require("@shared/utils/character")
local components = require("@components")

local function spawn_character_system(world: Jecs.World)
	for id, player in world:query(components.Player):without(components.Character) do
		if player.Character and player.Character.Parent ~= nil then
			world:set(id, components.Character, player.Character)
			character_utils.create_controller(player.Character :: any)
			print("Character created for player: ", player)
		end
	end
end

return {
	system = spawn_character_system,
	phase = Phases.PostSimulation,
}
