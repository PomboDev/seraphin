export type Character = Model & {
	Humanoid: Humanoid,
	HumanoidRootPart: Part,
	Top: Part,
	Mid: Part,
	Bottom: Part,
}

local function create_controller(character: Character)
	local controller_manager = Instance.new("ControllerManager")
	controller_manager.RootPart = character.HumanoidRootPart
	controller_manager.FacingDirection = character.HumanoidRootPart.CFrame.LookVector
	controller_manager.BaseMoveSpeed = 24
	controller_manager.BaseTurnSpeed = 100

	local ground_controller = Instance.new("GroundController")
	ground_controller.GroundOffset = 1
	ground_controller.BalanceRigidityEnabled = true

	local sliding_controller = Instance.new("GroundController")
	sliding_controller.GroundOffset = 1
	sliding_controller.Friction = 0.5
	sliding_controller.FrictionWeight = 1
	sliding_controller.BalanceRigidityEnabled = true

	local air_controller = Instance.new("AirController")
	air_controller.MaintainLinearMomentum = true
	air_controller.MaintainAngularMomentum = false
	air_controller.BalanceRigidityEnabled = true
	air_controller.MoveMaxForce = 175

	local ground_sensor = Instance.new("ControllerPartSensor")
	ground_sensor.SensorMode = Enum.SensorMode.Floor
	ground_sensor.SearchDistance = 1.5

	ground_sensor.Parent = character.HumanoidRootPart
	controller_manager.GroundSensor = ground_sensor
	controller_manager.Parent = character
	ground_controller.Parent = controller_manager
	air_controller.Parent = controller_manager
end

return {
	create_controller = create_controller,
}
