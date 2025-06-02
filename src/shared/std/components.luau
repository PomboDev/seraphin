local Jecs = require("@jecs")
local world = require("@world")

type noop = (...any) -> ()

type Id<T = any> = Jecs.Id<T>

export type State = {
	on_enter: (world: Jecs.World, entity: Id) -> () | noop,
	on_exit: (world: Jecs.World, entity: Id) -> () | noop,
	update: (world: Jecs.World, entity: Id, dt: number) -> () | noop,
}

export type StateGroup = {
	[string]: State,
}

export type StateMachine = {
	current: string,
	previous: string?,
}

export type StateMachines = {
	[StateGroup]: StateMachine,
}

export type TransitionQueue = {
	[StateGroup]: string,
}

export type CharacterController = ControllerManager & {
	AirController: AirController,
	GroundController: GroundController,
	SlidingController: GroundController,
}

export type Character = {
	Humanoid: Humanoid,
	HumanoidRootPart: Part & {
		GroundSensor: ControllerPartSensor,
		ClimbSensor: ControllerPartSensor,
	},
	ControllerManager: CharacterController,
	Top: Part,
	Visual: Part,
	Bottom: Part,
}

export type Health = {
	value: number,
	max_health: number,
	regen: number,
}

export type Stamina = {
	value: number,
	max_health: number,
	regen: number,
}

export type Movement = {
	acceleration: number,
	deceleration: number,
	friction: number,
	friction_weight: number,
	speed: number,
	turn_speed: number,
	slope_angle: number,
}

export type Jump = {
	jumps_remaining: number,
	jump_force: number,
	coyote_time: number,
	jump_cooldown: number,
}

export type Sensors = {
	floor: ControllerPartSensor,
	ladder: ControllerPartSensor,
	water: BuoyancySensor,
}

export type PhysicsControllers = {
	ground: GroundController,
	air: AirController,
	climb: ClimbController,
	swim: SwimController,
}

export type MovementTimers = {
	coyote_time: number,
	jump_buffer: number,
	jump_cooldown: number,
}

export type JumpState = {
	jumps_remaining: number,
	jump_force: number,
	sustain_time: number,
	sustain_active: boolean,
}

export type SlideState = {
	timer: number,
	sliding: boolean,
}

local components = {
	-- [COMPONENTS]
	-- Base
	Name = world:component() :: Id<string>,
	Camera = world:component() :: Id<Camera>,
	Player = world:component() :: Id<Player>,
	LocalPlayer = world:component() :: Id<Player>,

	-- State Machine Components
	StateMachines = world:component() :: Id<StateMachines>,
	TransitionQueue = world:component() :: Id<TransitionQueue>,
	StateInitialized = Jecs.tag() :: Id,

	-- Character
	Character = (world:component() :: any) :: Id<Character>,
	Health = world:component() :: Id<Health>,
	Stamina = world:component() :: Id<Stamina>,

	-- Movement Components
	Movement = world:component() :: Id<Movement>,
	Jump = world:component() :: Id<Jump>,
	MovementTimers = world:component() :: Id<MovementTimers>,
	JumpState = world:component() :: Id<JumpState>,
	SlideState = world:component() :: Id<SlideState>,
}

for name, component in components :: { [string]: Id } do
	world:set(component, Jecs.Name, name)
end

return table.freeze(components)
