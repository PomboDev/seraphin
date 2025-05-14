local Jecs = require("@jecs")
local components = require("@components")
local state_registry = require("@shared/utils/state_registry")

export type StateDefinition = components.State
export type StateMachine = components.StateMachine
export type StateMachines = components.StateMachines

local function get_state_machine(world: Jecs.World, entity: Jecs.Entity, state_group: any): StateMachine?
	local state_machines = world:get(entity, components.StateMachines)
	if not state_machines then
		return nil
	end

	return state_machines[state_group]
end

local function create_state_machine(
	world: Jecs.World,
	entity: Jecs.Entity,
	state_group: any,
	initial_state: string,
	initial_context: any?
): StateMachine
	local state_machines = world:get(entity, components.StateMachines) or {}

	if not state_machines[state_group] then
		state_machines[state_group] = {
			current = initial_state,
			previous = nil,
			context = initial_context or {},
		}
		world:set(entity, components.StateMachines, state_machines)
	end

	return state_machines[state_group]
end

local function transition(world: Jecs.World, entity: Jecs.Entity, state_group: any, new_state: string)
	local state_machines = world:get(entity, components.StateMachines)
	if not state_machines then
		return
	end

	local state_machine = state_machines[state_group]
	if not state_machine then
		return
	end

	if state_machine.current == new_state then
		return
	end

	local transition_queue = world:get(entity, components.TransitionQueue) or {}
	transition_queue[state_group] = new_state
	world:set(entity, components.TransitionQueue, transition_queue)
end

local function is_in_state(world: Jecs.World, entity: Jecs.Entity, state_group: any, state_name: string): boolean?
	local state_machine = get_state_machine(world, entity, state_group)
	return state_machine and state_machine.current == state_name
end

local function get_current_state(world: Jecs.World, entity: Jecs.Entity, state_group: any): string?
	local state_machine = get_state_machine(world, entity, state_group)
	return state_machine and state_machine.current
end

local function get_context(world: Jecs.World, entity: Jecs.Entity, state_group: any): any?
	local state_machine = get_state_machine(world, entity, state_group)
	return state_machine and state_machine.context
end

local function set_context(world: Jecs.World, entity: Jecs.Entity, state_group: any, context: any)
	local state_machines = world:get(entity, components.StateMachines)
	if not state_machines or not state_machines[state_group] then
		return
	end

	state_machines[state_group].context = context
	world:set(entity, components.StateMachines, state_machines)
end

local function register_state_group(state_group_id: string, state_group: any)
	state_registry.register_group(state_group_id, state_group)
	state_registry.register_handler(state_group_id, function(world, entity, context, new_state)
		transition(world, entity, state_group, new_state)
	end)
end

return table.freeze({
	get_state_machine = get_state_machine,
	create_state_machine = create_state_machine,
	transition = transition,
	is_in_state = is_in_state,
	get_current_state = get_current_state,
	get_context = get_context,
	set_context = set_context,
	register_state_group = register_state_group,
})
