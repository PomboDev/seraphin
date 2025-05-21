local Jecs = require("@jecs")
local PlanckRunService = require("@packages/planck-runservice")
local UserInputService = game:GetService("UserInputService")
local Phases = PlanckRunService.Phases

local components = require("@components")
local input_map = require("@shared/metadata/input_map")
local player_movement_states = require("@shared/metadata/states/player_movement")

local mouse_locked = true
local x_angle, y_angle = 0, 0
local smoothness = 0.05

local function get_camera_offset_for_state(state: string): Vector3
	if state == "crouching" then
		return Vector3.new(0, 0, 0)
	elseif state == "sliding" then
		return Vector3.new(0, -0.5, 0)
	else
		return Vector3.new(0, 1.5, 0)
	end
end

local function update_camera(world: Jecs.World)
	for _id, camera, character, state_machines in
		world:query(components.Camera, components.Character, components.StateMachines)
	do
		local root_part = character.HumanoidRootPart

		if input_map.unlock_mouse:pressed() then
			UserInputService.MouseBehavior = mouse_locked and Enum.MouseBehavior.LockCenter
				or Enum.MouseBehavior.Default
			mouse_locked = not mouse_locked
		end

		local state_machine = state_machines[player_movement_states :: any]
		local mouse_delta = UserInputService:GetMouseDelta()
		local offset = get_camera_offset_for_state(state_machine.current)

		x_angle -= (mouse_delta.X * smoothness)
		y_angle = math.clamp(y_angle - (mouse_delta.Y * smoothness), -90, 90)

		root_part.CFrame = CFrame.Angles(0, math.rad(x_angle), 0) + root_part.Position
		camera.CFrame = character.HumanoidRootPart.CFrame + offset
		camera.CFrame *= CFrame.Angles(math.rad(y_angle), 0, 0)
	end
end

return {
	system = update_camera,
	phase = Phases.PreRender,
}
