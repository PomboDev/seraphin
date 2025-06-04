local Planck = require("@packages/planck")

local Jecs = require("@jecs")
local remotes = require("@std/remotes")

local onEvent = Planck.onEvent
local event_fired, collect = onEvent(remotes.replication :: any, "OnClientEvent")

local client_ids = {} :: { [Jecs.Id]: Jecs.Id }

local function ecs_map_get(world: Jecs.World, id: Jecs.Id)
	local deserialised_id = client_ids[id]

	if not deserialised_id then
		if world:has(id, Jecs.Name) then
			deserialised_id = world:entity(id)
		else
			deserialised_id = world:entity()
		end

		client_ids[id] = deserialised_id
	end

	-- local deserialised_id = client_ids[id]
	-- if not deserialised_id then
	-- 	if world:has(id, Jecs.Name) then
	-- 		deserialised_id = world:entity(id)
	-- 	else
	-- 		if world:exists(id) then
	-- 			deserialised_id = world:entity()
	-- 		else
	-- 			deserialised_id = world:entity(id)
	-- 		end
	-- 	end
	-- 	client_ids[id] = deserialised_id
	-- end

	return deserialised_id
end

local function ecs_make_alive_id(world, id)
	local relationshipId = Jecs.ECS_PAIR_FIRST(id)
	local targetId = Jecs.ECS_PAIR_SECOND(id)

	relationshipId = ecs_map_get(world, relationshipId)
	targetId = ecs_map_get(world, targetId)

	return Jecs.pair(relationshipId, targetId)
end

function reconcile(world: Jecs.World)
	for _, snapshot in collect() do
		for id, map in snapshot :: any do
			id = (tonumber(id) :: any) :: Jecs.Id
			if Jecs.IS_PAIR(id) then
				id = ecs_make_alive_id(world, id)
			end

			local set = map.set
			if set then
				if Jecs.is_tag(world, id) then
					for _, entity in set do
						entity = ecs_map_get(world, entity)
						world:add(entity, id)
					end
				else
					local values = map.values
					for i, entity in set do
						entity = ecs_map_get(world, entity)
						world:set(entity, id, values[i])
					end
				end
			end

			local removed = map.removed

			if removed then
				for _, e in removed do
					if not world:contains(e) then
						continue
					end
					world:remove(e, id)
				end
			end
		end
	end
end

return {
	system = reconcile,
	runConditions = { event_fired },
}
