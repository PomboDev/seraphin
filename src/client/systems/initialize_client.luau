local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Jecs = require("@jecs")
local Planck = require("@packages/planck")

local components = require("@components")

local function initialize_client(world: Jecs.World)
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Custom
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

	world:set(components.LocalPlayer, components.LocalPlayer, Players.LocalPlayer)
	world:set(components.LocalPlayer, components.Camera, camera)
end

return {
	system = initialize_client,
	phase = Planck.Phase.PreStartup,
}
