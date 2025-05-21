--!optimize 2
--!native
--!nonstrict
--draft 4

local Jecs = require("@jecs")
local PlanckRunService = require("@packages/planck-runservice")
local Phases = PlanckRunService.Phases

local components = require("@components")
local scheduler = require("@std/scheduler")

local function spring_vector3(
	current: Vector3,
	velocity: Vector3,
	target: Vector3,
	zeta: number,
	omega: number,
	h: number
)
	local f = 1 + 2 * h * zeta * omega
	local oo = omega * omega
	local hoo = h * oo
	local hhoo = h * hoo
	local detInv = 1 / (f + hhoo)
	local detX = (current * f) + (velocity * h) + (target * hhoo)
	local detV = velocity + (target - current) * hoo
	current = detX * detInv
	velocity = detV * detInv
	return current, velocity
end

local halfLife = 0.5
local frequency = 18
local angularDisplacement = 1.5
local linearDisplacement = 0.0025

local spring_position: Vector3
local sprint_velocity: Vector3

local function update_camera_spring(world: Jecs.World)
	for _id, camera in world:query(components.Camera, components.Character) do
		local dt = scheduler:getDeltaTime()

		spring_position = spring_position or camera.CFrame.Position
		sprint_velocity = sprint_velocity or Vector3.new(0, 0, 0)

		local target = camera.CFrame.Position
		spring_position, sprint_velocity =
			spring_vector3(spring_position, sprint_velocity, target, halfLife, frequency, dt)

		local localSpringPosition = spring_position - target
		local springHeight = localSpringPosition:Dot(Vector3.yAxis)

		camera.CFrame *= CFrame.Angles(math.rad(-springHeight * angularDisplacement), 0, 0) + (localSpringPosition * linearDisplacement)
	end
end

return {
	system = update_camera_spring,
	phase = Phases.PreRender,
}
