local Jecs = require("@jecs")
local world = require("@world")

type noop = (...any) -> ()

type Id<T = any> = Jecs.Id<T>

export type CharacterController = ControllerManager & {
	AirController: AirController,
	GroundController: GroundController,
}

export type Character = Model & {
	Humanoid: Humanoid,
	HumanoidRootPart: Part & {
		ControllerPartSensor: ControllerPartSensor,
	},
	ControllerManager: CharacterController,
	Top: Part,
	Visual: Part,
	Bottom: Part,
}

export type State = {
	on_enter: (world: Jecs.World, entity: Id, context: any?) -> () | noop,
	on_exit: (world: Jecs.World, entity: Id, context: any?) -> () | noop,
	update: (world: Jecs.World, entity: Id, context: any?, dt: number) -> () | noop,
}

export type StateGroup = {
	[string]: State,
}

export type Health = {
	value: number,
	max_health: number,
	regen: number,
}

export type StateMachine = {
	current: string,
	previous: string?,
	context: any?,
}

export type StateMachines = {
	[StateGroup]: StateMachine,
}

export type TransitionQueue = {
	[StateGroup]: string,
}

local components = {
	-- [COMPONENTS]
	-- Base
	LocalPlayer = world:component() :: Id<Player>,
	Player = world:component() :: Id<Player>,
	Name = world:component() :: Id<string>,

	-- State Machine Components
	StateMachines = world:component() :: Id<StateMachines>,
	TransitionQueue = world:component() :: Id<TransitionQueue>,
	StateInitialized = Jecs.tag() :: Id,

	-- Character
	Character = (world:component() :: any) :: Id<Character>,
	Health = world:component() :: Id<Health>,
}

for name, component in components :: { [string]: Id } do
	world:set(component, Jecs.Name, name)
end

return table.freeze(components)
