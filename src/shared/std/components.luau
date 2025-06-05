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

export type CharacterController = {
	AirController: AirController,
	GroundController: GroundController,
	SlidingController: GroundController,
	BaseMoveSpeed: number,
	MovingDirection: Vector3,
	FacingDirection: Vector3,
	ActiveController: GroundController | AirController | ClimbController | SwimController,
}

local components = {}

-- [COMPONENTS]
-- Network
components.Networked = Jecs.tag() :: Id
components.NetworkedPair = Jecs.tag() :: Id

-- Base
components.Camera = world:component() :: Id<Camera>
components.Player = world:component() :: Id<Player>
components.LocalPlayer = world:component() :: Id<Player>
components.Name = world:component() :: Id<string>
components.Position = world:component() :: Id<Vector3>
components.Rotation = world:component() :: Id<Vector3>
components.Velocity = world:component() :: Id<Vector3>

-- State Machine Components
export type StateMachines = {
	[StateGroup]: StateMachine,
}
components.StateMachines = world:component() :: Id<StateMachines>

export type TransitionQueue = {
	[StateGroup]: string,
}
components.TransitionQueue = world:component() :: Id<TransitionQueue>
components.StateInitialized = Jecs.tag() :: Id

-- Character
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
components.Character = world:component() :: Id<Character>

export type Health = {
	value: number,
	max_health: number,
	regen: number,
}
components.Health = world:component() :: Id<Health>

export type Stamina = {
	value: number,
	max_stamina: number,
	regen: number,
}
components.Stamina = world:component() :: Id<Stamina>
components.Animation = world:component() :: Id

-- Movement Components
export type Movement = {
	acceleration: number,
	deceleration: number,
	friction: number,
	friction_weight: number,
	speed: number,
	turn_speed: number,
	slope_angle: number,
}
components.Movement = world:component() :: Id<Movement>

export type Jump = {
	jumps_remaining: number,
	jump_force: number,
	coyote_time: number,
	jump_cooldown: number,
}
components.Jump = world:component() :: Id<Jump>

export type MovementTimers = {
	coyote_time: number,
	jump_buffer: number,
	jump_cooldown: number,
}
components.MovementTimers = world:component() :: Id<MovementTimers>

export type JumpState = {
	jumps_remaining: number,
	jump_force: number,
	sustain_time: number,
	sustain_active: boolean,
}
components.JumpState = world:component() :: Id<JumpState>

export type SlideState = {
	timer: number,
	sliding: boolean,
}
components.SlideState = world:component() :: Id<SlideState>

-- Spatial Grid
components.Voxel = Jecs.tag() :: Id

-- Entities
components.Npc = Jecs.component() :: Id<number>
components.Friendly = Jecs.tag() :: Id
components.Neutral = Jecs.tag() :: Id
components.Hostile = Jecs.tag() :: Id

-- Projectile System
components.Weapon = world:component() :: Id<number>

export type Ammo = {
	value: number,
	max_ammo: number,
	reload_time: number,
}
components.Ammo = world:component() :: Id<Ammo>
components.FireRate = world:component() :: Id<number>
components.Damage = world:component() :: Id<number>
components.Range = world:component() :: Id<number>

components.ProjectileWeapon = Jecs.tag() :: Id
components.HitscanWeapon = Jecs.tag() :: Id
-- components.BeamWeapon = Jecs.tag() :: Id
-- components.MeleeWeapon = Jecs.tag() :: Id

components.Projectile = Jecs.tag() :: Id
components.Gravity = world:component() :: Id<number>

-- components.Explosive = Jecs.tag() :: Id
-- components.Homing = Jecs.tag() :: Id
-- components.Bouncing = Jecs.tag() :: Id
-- components.Piercing = Jecs.tag() :: Id
-- components.Ricochet = Jecs.tag() :: Id

-- components.Burning = Jecs.tag() :: Id
-- components.Poisoned = Jecs.tag() :: Id
-- components.Frozen = Jecs.tag() :: Id
-- components.Stunned = Jecs.tag() :: Id
-- components.Bleeding = Jecs.tag() :: Id

components.Bullet = Jecs.tag() :: Id
-- components.Rocket = Jecs.tag() :: Id
-- components.Laser = Jecs.tag() :: Id
-- components.Magic = Jecs.tag() :: Id
-- components.Plasma = Jecs.tag() :: Id

local networked_components = {
	"Name",
	"Player",
	"Position",
	"Rotation",
	"Health",
	"Stamina",
	"Weapon",
	"Ammo",
	"Npc",
	"Friendly",
	"Neutral",
	"Hostile",
	"BulletData",
}

local networked_pairs = {
	"Friendly",
	"Neutral",
	"Hostile",
	"Projectile",
	"Explosive",
	"Homing",
	"Bouncing",
	"Piercing",
	"Gravity",
	"Ricochet",
	"Burning",
	"Poisoned",
	"Frozen",
	"Stunned",
	"Bleeding",
	"Bullet",
	"Rocket",
	"Laser",
	"Magic",
	"Plasma",
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
