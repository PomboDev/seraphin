local Jecs = require("@jecs")
local PlanckRunService = require("@packages/planck-runservice")

local Phases = PlanckRunService.Phases
local input_library = require("@shared/utils/input_library")

local function update_inputs(_world: Jecs.World)
	input_library.update()
end

return {
	system = update_inputs,
	phase = Phases.PreSimulation,
}
