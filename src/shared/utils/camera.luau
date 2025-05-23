local Players = game:GetService("Players")
local PlayerModule = Players.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")

local CameraModule = PlayerModule:WaitForChild("CameraModule")

return {
	Input = require(CameraModule:WaitForChild("CameraInput") :: ModuleScript) :: { getRotation: (dt: number) -> Vector2 },
	Utils = require(CameraModule:WaitForChild("CameraUtils") :: ModuleScript) :: {
		setMouseBehaviorOverride: (behavior: Enum.MouseBehavior) -> (),
		setMouseIconOverride: (icon: string) -> (),
		restoreMouseIcon: () -> (),
	},
}
