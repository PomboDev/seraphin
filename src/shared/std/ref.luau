local Jecs = require("@jecs")
local world = require("@world")
local refs = require("@std/refs")

local function ref(key: string?): Jecs.Entity
	if not key then
		return world:entity()
	end

	local entity = refs[key]
	if not entity then
		entity = world:entity()
		refs[key] = entity
	end

	return entity
end

return ref
