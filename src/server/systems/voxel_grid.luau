local Planck = require("@packages/planck")

local Jecs = require("@jecs")
local components = require("@components")

local world = require("@world")
local ChildOf = Jecs.ChildOf

local GRID_SIZE = 100
local voxel_map = {}
local entity_map = {} :: { [Jecs.Id]: { [Jecs.Id]: any } }

local function get_or_create_voxel_for_hash(hash: Vector3): Jecs.Id
	local voxel_id = voxel_map[hash]
	if not voxel_id then
		voxel_id = world:entity()
		world:add(voxel_id, components.Voxel)
		world:set(voxel_id, components.Position, hash)
		voxel_map[hash] = voxel_id
		entity_map[voxel_id] = {}
	end
	return voxel_id
end

function create_voxel_grid_system()
	world:added(components.Position, function(entity, _id, new_position_value: Vector3)
		if world:has(entity, components.Voxel) then
			return
		end

		local new_voxel_id = get_or_create_voxel_for_hash(
			Vector3.new(
				math.floor(new_position_value.X / GRID_SIZE),
				math.floor(new_position_value.Y / GRID_SIZE),
				math.floor(new_position_value.Z / GRID_SIZE)
			)
		)

		world:add(entity, Jecs.pair(ChildOf, new_voxel_id))
	end)

	world:changed(components.Position, function(entity, _id, new_position_value: Vector3)
		if world:has(entity, components.Voxel) then
			return
		end

		local previous_voxel_id = world:get(entity, components.Voxel) :: Jecs.Id
		local new_voxel_id = get_or_create_voxel_for_hash(
			Vector3.new(
				math.floor(new_position_value.X / GRID_SIZE),
				math.floor(new_position_value.Y / GRID_SIZE),
				math.floor(new_position_value.Z / GRID_SIZE)
			)
		)
		if previous_voxel_id ~= new_voxel_id then
			if previous_voxel_id then
				entity_map[previous_voxel_id][entity] = nil
				world:remove(entity, Jecs.pair(ChildOf, previous_voxel_id))
			end

			world:add(entity, Jecs.pair(ChildOf, new_voxel_id) :: any)
			entity_map[new_voxel_id][entity] = true
		end
	end)

	world:removed(components.Position, function(entity)
		if world:has(entity, components.Voxel) then
			return
		end

		local current_voxel_id = world:get(entity, components.Voxel) :: Jecs.Id
		if current_voxel_id then
			world:remove(entity, Jecs.pair(ChildOf, current_voxel_id))
			entity_map[current_voxel_id][entity] = nil
		end
	end)
end

return {
	system = create_voxel_grid_system(),
	phase = Planck.Phase.Startup,
}
