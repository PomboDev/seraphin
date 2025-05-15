local input = require("@shared/utils/input_library")
local action = input.action

local input_map = {
	move_delta = action({
		Enum.KeyCode.Thumbstick1,
		Enum.KeyCode.W,
		Enum.KeyCode.S,
		Enum.KeyCode.A,
		Enum.KeyCode.D,
	}),

	input_delta = action({ Enum.UserInputType.MouseMovement, Enum.KeyCode.Thumbstick2 }),
	shoot = action({
		Enum.UserInputType.MouseButton1,
		Enum.UserInputType.Touch,
		Enum.KeyCode.ButtonR2,
	}),
	unlock_mouse = action({
		Enum.KeyCode.C,
	}),

	crouch = action({ Enum.KeyCode.LeftControl, Enum.KeyCode.ButtonR3 }),
	jump = action({ Enum.KeyCode.Space, Enum.KeyCode.ButtonX }),
}

return table.freeze(input_map)
