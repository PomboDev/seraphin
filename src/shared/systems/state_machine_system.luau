--!optimize 2
--!native
--!strict
local RunService = game:GetService("RunService")
--draft 4

local Jecs = require("@jecs")
local PlanckRunService = require("@packages/planck-runservice")

local components = require("@components")
local scheduler = require("@std/scheduler")

local Phases = PlanckRunService.Phases

local function state_machine_system(world: Jecs.World)
	for id, state_machines in world:query(components.StateMachines):without(components.StateInitialized) do
		world:add(id, components.StateInitialized)

		for states, state_machine in state_machines do
			local state = states[state_machine.current]
			state.on_enter(world, id)
		end
	end

	for id, transition_queue, state_machines in world:query(components.TransitionQueue, components.StateMachines) do
		for states, new_state in transition_queue do
			local state_machine = state_machines[states]
			local current_state = states[state_machine.current]
			local next_state = states[new_state]

			state_machine.previous = state_machine.current
			state_machine.current = new_state

			current_state.on_exit(world, id)
			next_state.on_enter(world, id)
		end

		world:set(id, components.StateMachines, state_machines)
		world:remove(id, components.TransitionQueue)
	end

	for id, state_machines in world:query(components.StateMachines) do
		for states, state_machine in state_machines do
			local dt = scheduler:getDeltaTime()
			states[state_machine.current].update(world, id, dt)
		end
	end
end

local function timePassed(time: number)
	local storedTime: number?

	return function()
		if storedTime == nil or os.clock() - storedTime >= time then
			storedTime = os.clock()
			return true
		end

		return false
	end
end

if RunService:IsClient() then
	return {
		system = state_machine_system,
		phase = Phases.PreRender,
	}
else
	return {
		system = state_machine_system,
		phase = Phases.PostSimulation,
		runCondition = timePassed(0.1),
	}
end
