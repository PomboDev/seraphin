local Spring = {}
Spring.__index = Spring

function Spring.new(initial: any, damping: number, frequency: number)
	return setmetatable({
		value = initial,
		velocity = typeof(initial) == "Vector3" and Vector3.zero or 0,
		damping = damping or 1,
		frequency = frequency or 10,
	}, Spring)
end

function Spring:step(target: any, dt: number)
	local zeta = self.damping :: number
	local omega = self.frequency :: number
	local x, v, xt = self.value :: any, self.velocity :: any, target :: any
	local f = 1 + 2 * dt * zeta * omega
	local oo = omega * omega
	local hoo = dt * oo
	local hhoo = dt * hoo
	local detInv = 1 / (f + hhoo)
	local detX = f * x + dt * v + hhoo * xt
	local detV = v + hoo * (xt - x)
	self.value = detX * detInv
	self.velocity = detV * detInv
	return self.value
end

return Spring
