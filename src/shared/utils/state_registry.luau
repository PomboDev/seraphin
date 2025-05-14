local registry = {}
local state_groups = {}

local function register_group(groupId: string, groupModule: any)
	state_groups[groupId] = groupModule
end

local function get_group(groupId: string): any?
	return state_groups[groupId]
end

local function register_handler(groupId: string, handler: (any, any, any, string) -> ())
	registry[groupId] = {
		transition = handler,
	}
end

local function get_handler(groupId: string): ((any, any, any, string) -> ())?
	return registry[groupId] and registry[groupId].transition
end

local function create_transition(groupId: string)
	return function(world, entity, context, stateName)
		local handler = get_handler(groupId)
		if handler then
			print(context, stateName)
			handler(world, entity, context, stateName)
		else
			warn("No transition handler registered for state group: " .. groupId)
		end
	end
end

return table.freeze({
	register_group = register_group,
	get_group = get_group,
	register_handler = register_handler,
	get_handler = get_handler,
	create_transition = create_transition,
})
