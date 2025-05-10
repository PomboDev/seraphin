local Jecs = require("@jecs")
local PlanckRunService = require("@packages/planck-runservice")

local Phases = PlanckRunService.Phases
local components = require("@components")

local function create_controller(character: Model & {
	Humanoid: Humanoid,
	HumanoidRootPart: Part,
	Top: Part,
	Mid: Part,
	Bottom: Part,
})
	local ControllerManager = Instance.new("ControllerManager")
	ControllerManager.RootPart = character.HumanoidRootPart
	ControllerManager.FacingDirection = character.HumanoidRootPart.CFrame.LookVector
	ControllerManager.BaseMoveSpeed = 16

	local GroundController = Instance.new("GroundController")
	GroundController.GroundOffset = character.Humanoid.HipHeight
	GroundController.BalanceRigidityEnabled = true
	GroundController.Parent = ControllerManager

	local AirController = Instance.new("AirController")
	AirController.MaintainLinearMomentum = true
	AirController.MaintainAngularMomentum = false
	AirController.BalanceRigidityEnabled = true
	AirController.Parent = ControllerManager

	local GroundSensor = Instance.new("ControllerPartSensor")
	GroundSensor.SensorMode = Enum.SensorMode.Floor
	GroundSensor.SearchDistance = GroundController.GroundOffset + 0.5
	GroundSensor.Name = "GroundSensor"

	ControllerManager.GroundSensor = GroundSensor

	GroundSensor.Parent = character.HumanoidRootPart
	ControllerManager.Parent = character
end

local function spawn_character_system(world: Jecs.World)
	for id, player in world:query(components.Player):without(components.Character) do
		if player.Character then
			world:set(id, components.Character, player.Character)
			create_controller(player.Character :: any)
			print("Character created for player: ", player)
		end
	end
end

return {
	system = spawn_character_system,
	phase = Phases.PostSimulation,
}
