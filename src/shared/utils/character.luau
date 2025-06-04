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
	controller_manager.BaseTurnSpeed = 0

	local ground_controller = Instance.new("GroundController")
	ground_controller.Name = "GroundController"
	ground_controller.GroundOffset = 1
	ground_controller.BalanceRigidityEnabled = true

	local sliding_controller = Instance.new("GroundController")
	sliding_controller.Name = "SlidingController"
	sliding_controller.GroundOffset = 1
	sliding_controller.Friction = 0
	sliding_controller.FrictionWeight = 0
	sliding_controller.BalanceRigidityEnabled = true

	local air_controller = Instance.new("AirController")
	air_controller.MaintainLinearMomentum = true
	air_controller.MaintainAngularMomentum = false
	air_controller.BalanceRigidityEnabled = true
	air_controller.MoveMaxForce = 175

	local ground_sensor = Instance.new("ControllerPartSensor")
	ground_sensor.Name = "GroundSensor"
	ground_sensor.SensorMode = Enum.SensorMode.Floor
	ground_sensor.SearchDistance = 2.5

	local climbing_sensor = Instance.new("ControllerPartSensor")
	climbing_sensor.Name = "ClimbSensor"
	climbing_sensor.SensorMode = Enum.SensorMode.Ladder
	climbing_sensor.SearchDistance = 1.5

	ground_sensor.Parent = character.HumanoidRootPart
	climbing_sensor.Parent = character.HumanoidRootPart

	controller_manager.GroundSensor = ground_sensor
	controller_manager.ClimbSensor = climbing_sensor
	controller_manager.Parent = character

	air_controller.Parent = controller_manager
	ground_controller.Parent = controller_manager
	sliding_controller.Parent = controller_manager
end

return {
	create_controller = create_controller,
}
