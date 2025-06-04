local components = require("@components")
local serializers = {} :: { [any]: any }

serializers[components.Position] = {
	serialize = function(position: Vector3)
		local buf = buffer.create(12)
		buffer.writef32(buf, 0, position.X)
		buffer.writef32(buf, 4, position.Y)
		buffer.writef32(buf, 8, position.Z)
		return buffer.tostring(buf)
	end,
	deserialize = function(data: string)
		local buf = buffer.fromstring(data)
		return Vector3.new(buffer.readf32(buf, 0), buffer.readf32(buf, 4), buffer.readf32(buf, 8))
	end,
}

serializers[components.Rotation] = {
	serialize = function(rotation: Vector3)
		local buf = buffer.create(6)
		buffer.writei16(buf, 0, math.round(rotation.X * 100))
		buffer.writei16(buf, 2, math.round(rotation.Y * 100))
		buffer.writei16(buf, 4, math.round(rotation.Z * 100))
		return buffer.tostring(buf)
	end,
	deserialize = function(data: string)
		local buf = buffer.fromstring(data)
		return Vector3.new(buffer.readi16(buf, 0) / 100, buffer.readi16(buf, 2) / 100, buffer.readi16(buf, 4) / 100)
	end,
}

serializers[components.Health] = {
	serialize = function(health: components.Health)
		local buf = buffer.create(6)
		buffer.writei16(buf, 0, health.value)
		buffer.writei16(buf, 2, health.max_health)
		buffer.writei16(buf, 4, health.regen)
		return buffer.tostring(buf)
	end,
	deserialize = function(data: string)
		local buf = buffer.fromstring(data)
		return {
			value = buffer.readi16(buf, 0),
			max_health = buffer.readi16(buf, 2),
			regen = buffer.readi16(buf, 4),
		}
	end,
}

serializers[components.Stamina] = {
	serialize = function(stamina: components.Stamina)
		local buf = buffer.create(6)
		buffer.writei16(buf, 0, stamina.value)
		buffer.writei16(buf, 2, stamina.max_stamina)
		buffer.writei16(buf, 4, stamina.regen)
		return buffer.tostring(buf)
	end,
	deserialize = function(data: string)
		local buf = buffer.fromstring(data)
		return {
			value = buffer.readi16(buf, 0),
			max_stamina = buffer.readi16(buf, 2),
			regen = buffer.readi16(buf, 4),
		}
	end,
}

local function serialize(componentId: any, value: any): any
	local serializer = serializers[componentId]
	if serializer then
		return serializer.serialize(value)
	end
	return value
end

local function deserialize(componentId: any, data: any): any
	local serializer = serializers[componentId]
	if serializer then
		return serializer.deserialize(data)
	end
	return data
end

local function needsSerialization(componentId: any): boolean
	return serializers[componentId] ~= nil
end

return {
	serialize = serialize,
	deserialize = deserialize,
	needsSerialization = needsSerialization,
	serializers = serializers,
}
