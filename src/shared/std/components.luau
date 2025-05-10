local Jecs = require("@jecs")
local world = require("@world")

type noop = (...any) -> ()

type Entity<T = unknown> = Jecs.Entity<T>

type State = {
	on_enter: (world: Jecs.World, entity: Entity, context: any?) -> () | noop,
	on_exit: (world: Jecs.World, entity: Entity, context: any?) -> () | noop,
	update: (world: Jecs.World, entity: Entity, dt: number, context: any?) -> () | noop,
}

type StateGroup = {
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
	Name = world:component() :: Entity<string>,
	Player = world:component() :: Entity<Player>,
	LocalPlayer = world:component() :: Entity<Player>,

	-- State Machine Components
	StateMachines = world:component() :: Entity<StateMachines>,
	TransitionQueue = world:component() :: Entity<TransitionQueue>,
	StateInitialized = world:component() :: Entity,

	-- Character
	Character = world:component() :: Entity<Model>,
	Health = world:component() :: Entity<Health>,
}

for name, component in components do
	world:set(component, Jecs.Name, name)
end

return table.freeze(components)
