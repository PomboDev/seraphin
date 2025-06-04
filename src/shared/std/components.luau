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

export type CharacterController = {
	AirController: AirController,
	GroundController: GroundController,
	SlidingController: GroundController,
	BaseMoveSpeed: number,
	MovingDirection: Vector3,
	FacingDirection: Vector3,
	ActiveController: GroundController | AirController | ClimbController | SwimController,
}

export type Character = {
	Humanoid: Humanoid,
	HumanoidRootPart: {
		AssemblyLinearVelocity: Vector3,
		AssemblyAngularVelocity: Vector3,
		Position: Vector3,
		CFrame: CFrame,
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
	max_stamina: number,
	regen: number,
}

export type Animation = {
	animations: { [string]: AnimationTrack },
	animation_speed: number,
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

export type Position = Vector3

export type Rotation = Vector3

local components = {}

-- [COMPONENTS]
-- Network
components.Networked = Jecs.tag() :: Id
components.NetworkedPair = Jecs.tag() :: Id

-- Base
components.Camera = world:component() :: Id<Camera>
components.Player = world:component() :: Id<Player>
components.LocalPlayer = world:component() :: Id<Player>
components.Position = world:component() :: Id<Position>
components.Rotation = world:component() :: Id<Rotation>

-- State Machine Components
components.StateMachines = world:component() :: Id<StateMachines>
components.TransitionQueue = world:component() :: Id<TransitionQueue>
components.StateInitialized = Jecs.tag() :: Id

-- Character
components.Character = world:component() :: Id<Character>
components.Health = world:component() :: Id<Health>
components.Stamina = world:component() :: Id<Stamina>
components.Animation = world:component() :: Id<Animation>

-- Movement Components
components.Movement = world:component() :: Id<Movement>
components.Jump = world:component() :: Id<Jump>
components.MovementTimers = world:component() :: Id<MovementTimers>
components.JumpState = world:component() :: Id<JumpState>
components.SlideState = world:component() :: Id<SlideState>

-- Spatial Grid
components.Voxel = Jecs.tag() :: Id

-- Entities
components.Npc = Jecs.component() :: Id<number>
components.Friendly = Jecs.tag() :: Id
components.Neutral = Jecs.tag() :: Id
components.Hostile = Jecs.tag() :: Id

local networked_components = {
	"Name",
	"Player",
	"Position",
	"Rotation",
	"Health",
	"Stamina",
	"Npc",
	"Friendly",
	"Neutral",
	"Hostile",
}

local networked_pairs = {
	"Friendly",
	"Neutral",
	"Hostile",
}

for name, component in components :: { [string]: Id } do
	if table.find(networked_components, name) then
		world:add(component, components.Networked)
	end

	if table.find(networked_pairs, name) then
		world:add(component, components.NetworkedPair)
	end

	world:set(component, Jecs.Name, name)
end

return table.freeze(components)
