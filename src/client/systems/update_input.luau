local UserInputService = game:GetService("UserInputService")

local Jecs = require("@jecs")
local PlanckRunService = require("@packages/planck-runservice")

local Phases = PlanckRunService.Phases
local input_library = require("@shared/utils/input_library")
local input_map = require("@shared/metadata/input_map")

local function update_inputs(_world: Jecs.World)
	input_library.update()
end

return {
	system = update_inputs,
	phase = Phases.PreSimulation,
}
