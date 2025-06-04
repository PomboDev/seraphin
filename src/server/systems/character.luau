local Jecs = require("@jecs")
local PlanckRunService = require("@packages/planck-runservice")

local Phases = PlanckRunService.Phases
local character_utils = require("@shared/utils/character")
local components = require("@components")

local function spawn_character_system(world: Jecs.World)
	for id, player in world:query(components.Player):without(components.Character) do
		if player.Character and player.Character.Parent ~= nil then
			world:set(id, components.Character, player.Character)
			world:set(id, components.Health, {
				value = 100,
				max_health = 100,
				regen = 10,
			})
			character_utils.create_controller(player.Character :: any)
		end
	end
end

return {
	system = spawn_character_system,
	phase = Phases.PostSimulation,
}
