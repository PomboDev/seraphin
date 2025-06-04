local Players = game:GetService("Players")
local Planck = require("@packages/planck")
local PlanckRunService = require("@packages/planck-runservice")

local Jecs = require("@jecs")
local components = require("@components")
local remotes = require("@std/remotes")

local onEvent = Planck.onEvent
local _, collect = onEvent(Players, "PlayerAdded")

export type Snapshot = {
	[string]: {
		set: { Jecs.Entity }?,
		values: { any }?,
		removed: { Jecs.Entity }?,
	},
}

function create_replication_system()
	local world = require("@world")

	local storages = {} :: { [Jecs.Entity]: { [Jecs.Entity]: any } }
	local networked_components = {}
	local networked_pairs = {}

	for component in world:each(components.Networked) do
		local name = world:get(component, Jecs.Name) :: keyof<typeof(components)>
		if (components :: any)[name] == nil then
			continue
		end

		storages[component] = {}

		table.insert(networked_components, component)
	end

	for relation in world:each(components.NetworkedPair) do
		local name = world:get(relation, Jecs.Name) :: keyof<typeof(components)>
		if not (components :: any)[name] then
			continue
		end
		table.insert(networked_pairs, relation)
	end

	for _, component in networked_components do
		local name = world:get(component, Jecs.Name) :: keyof<typeof(components)>
		if not (components :: any)[name] then
			error(`Networked Component (%id{component}%name{name})`)
		end
		local is_tag = Jecs.is_tag(world, component)
		local storage = storages[component]
		if is_tag then
			world:added(component, function(entity)
				storage[entity] = true
			end)
		else
			world:added(component, function(entity, _, value)
				storage[entity] = value
			end)
			world:changed(component, function(entity, _, value)
				storage[entity] = value
			end)
		end

		world:removed(component, function(entity)
			storage[entity] = "Jecs.Remove"
		end)
	end

	for _, relation in networked_pairs do
		world:added(relation, function(entity, id, value)
			local is_tag = Jecs.is_tag(world, id)
			local storage = storages[id]
			if not storage then
				storage = {}
				storages[id] = storage
			end
			if is_tag then
				storage[entity] = true
			else
				storage[entity] = value
			end
		end)

		world:changed(relation, function(entity, id, value)
			local is_tag = Jecs.is_tag(world, id)
			if is_tag then
				return
			end

			local storage = storages[id]
			if not storage then
				storage = {}
				storages[id] = storage
			end

			storage[entity] = value
		end)

		world:removed(relation, function(entity, id)
			local storage = storages[id]
			if not storage then
				storage = {}
				storages[id] = storage
			end

			storage[entity] = "Jecs.Remove"
		end)
	end

	print("Replication system initialized with components:", networked_components, "and pairs:", networked_pairs)
	return function()
		local snapshot_lazy: Snapshot
		local set_ids_lazy: { Jecs.Entity }

		for _, player in collect() do
			if not snapshot_lazy then
				snapshot_lazy, set_ids_lazy = {}, {}

				for component, _storage in storages do
					local set_values = {}
					local set_n = 0

					local q = world:query(component)
					local is_tag = Jecs.is_tag(world, component)
					for _, archetype in q:archetypes() do
						local entities = archetype.entities
						local entities_len = #entities
						table.move(entities, 1, entities_len, set_n + 1, set_ids_lazy)
						if is_tag then
							set_values = table.create(entities_len, true)
						else
							local column = archetype.columns[archetype.records[component]]
							table.move(column, 1, entities_len, set_n + 1, set_values)
						end

						set_n += entities_len
					end

					local set = table.move(set_ids_lazy, 1, set_n, 1, {})
					snapshot_lazy[tostring(component)] = {
						set = if set_n > 0 then set else nil,
						values = if set_n > 0 then set_values else nil,
					}
				end
			end

			remotes.replication:FireClient(player, snapshot_lazy)
		end

		local snapshot = {} :: Snapshot

		local set_ids = {}
		local removed_ids = {}

		for component, storage in storages do
			local set_values = {} :: { any }
			local set_n = 0
			local removed_n = 0
			for e, v in storage do
				if v ~= "Jecs.Remove" then
					set_n += 1
					set_ids[set_n] = e
					set_values[set_n] = v or true
				elseif not world:contains(e) then
					removed_n += 1
					removed_ids[removed_n] = e
				end
			end

			table.clear(storage)

			local dirty = false

			if set_n > 0 or removed_n > 0 then
				dirty = true
			end

			if dirty then
				local removed = table.move(removed_ids, 1, removed_n, 1, {}) :: { Jecs.Entity }
				local set = table.move(set_ids, 1, set_n, 1, {}) :: { Jecs.Entity }
				snapshot[tostring(component)] = {
					set = if set_n > 0 then set else nil,
					values = if set_n > 0 then set_values else nil,
					removed = if removed_n > 0 then removed else nil,
				}
			end
		end
		if next(snapshot) ~= nil then
			remotes.replication:FireAllClients(snapshot)
		end
	end
end

return {
	system = create_replication_system(),
	phase = PlanckRunService.Phases.PostSimulation,
}
