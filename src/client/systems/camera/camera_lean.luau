--!optimize 2
--!native
--!strict
--draft 4

local Jecs = require("@jecs")
local PlanckRunService = require("@packages/planck-runservice")
local Phases = PlanckRunService.Phases

local components = require("@components")
local scheduler = require("@std/scheduler")

local attackDamping = 0.15
local decayDamping = 0.15
local walkStrength = 1 / 1000
local slideStrength = 5 / 1000
local strengthResponse = 5

local _dampedAcceleration: Vector3
local _dampedAccelerationVel: Vector3
local _smoothStrength: number = 0

local function lerp(a: number, b: number, t: number)
	return a + (b - a) * t
end

local function smooth_damp_vec3(
	current: Vector3,
	target: Vector3,
	velocity: Vector3,
	smoothTime: number,
	deltaTime: number
)
	local omega = 2 / math.max(smoothTime, 1e-4)
	local x = omega * deltaTime
	local exp = 1 / (1 + x + 0.48 * x * x + 0.235 * x * x * x)
	local change = current - target
	local temp = (velocity + omega * change) * deltaTime
	local newVel = (velocity - omega * temp) * exp
	local newPos = target + (change + temp) * exp
	return newPos, newVel
end

local function project_on_plane(v: Vector3, n: Vector3)
	return v - n * v:Dot(n)
end

local function update_camera_lean(world: Jecs.World)
	local dt = scheduler:getDeltaTime()
	for _id, camera, character in world:query(components.Camera, components.Character) do
		_dampedAcceleration = _dampedAcceleration or Vector3.new()
		_dampedAccelerationVel = _dampedAccelerationVel or Vector3.new()

		local rootPart = character.HumanoidRootPart
		local worldAcceleration = rootPart.AssemblyLinearVelocity
		local acceleration = rootPart.CFrame:VectorToObjectSpace(worldAcceleration)
		local sliding = false

		local planarAcceleration = project_on_plane(-acceleration, Vector3.yAxis)
		local damping = planarAcceleration.Magnitude > _dampedAcceleration.Magnitude and attackDamping or decayDamping

		_dampedAcceleration, _dampedAccelerationVel =
			smooth_damp_vec3(_dampedAcceleration, planarAcceleration, _dampedAccelerationVel, damping, dt)

		local leanAxis = _dampedAcceleration.Magnitude > 0 and _dampedAcceleration.Unit:Cross(Vector3.yAxis).Unit
			or Vector3.new(0, 0, 0)
		local effectiveStrength = sliding and slideStrength or walkStrength

		_smoothStrength = lerp(_smoothStrength, effectiveStrength, 1 - math.exp(-strengthResponse * dt))

		if leanAxis.Magnitude > 0 then
			local angle = _dampedAcceleration.Magnitude * _smoothStrength
			camera.CFrame *= CFrame.fromAxisAngle(leanAxis, angle)
		end
	end
end

return {
	system = update_camera_lean,
	phase = Phases.PreRender,
}
