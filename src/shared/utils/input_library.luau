local UserInputService = game:GetService("UserInputService")

export type Input = Enum.KeyCode | Enum.UserInputType

export type InputStates<T> = { [string]: T }

export type ShortInputType = {
	read_analog: (input_name: string, deadzone: number?) -> Vector2,
	pressed: (input_name: string) -> boolean,
	down: (input_name: string) -> boolean,
	released: (input_name: string) -> boolean,
	up: (input_name: string) -> boolean,
	disable: () -> (),
	enable: () -> (),
	update: () -> (),
	controls: () -> { string },
	states: () -> InputStates<boolean>,
	init: () -> ShortInputType,
	destroy: () -> (),
}

export type Action = {
	pressed: (self: any) -> boolean,
	down: (self: any) -> boolean,
	released: (self: any) -> boolean,
	up: (self: any) -> boolean,
	read: (self: any, deadzone: number | nil) -> Vector2,
}

local default_deadzone: number = 0.05

local connections: { RBXScriptConnection } = {}
local enabled: boolean = true
local states: InputStates<boolean> = {}
local previous_states: InputStates<boolean> = {}
local analog_values: InputStates<Vector2> = {}

local function setup_connections(): ()
	for _, connection in connections do
		connection:Disconnect()
	end

	connections = {}

	table.insert(
		connections,
		UserInputService.InputBegan:Connect(function(input: InputObject, game_processed: boolean)
			if not enabled or game_processed then
				return
			end

			local input_type = input.UserInputType
			local key_code = input.KeyCode

			local input_name = (key_code ~= Enum.KeyCode.Unknown) and key_code.Name or input_type.Name
			states[input_name] = true
		end)
	)

	table.insert(
		connections,
		UserInputService.InputEnded:Connect(function(input: InputObject, game_processed: boolean)
			if not enabled or game_processed then
				return
			end

			local input_type = input.UserInputType
			local key_code = input.KeyCode

			local input_name = (key_code ~= Enum.KeyCode.Unknown) and key_code.Name or input_type.Name
			states[input_name] = false
		end)
	)

	table.insert(
		connections,
		UserInputService.InputChanged:Connect(function(input: InputObject, game_processed: boolean)
			if not enabled or game_processed then
				return
			end

			if
				input.KeyCode == Enum.KeyCode.Thumbstick1
				or input.KeyCode == Enum.KeyCode.Thumbstick2
				or input.KeyCode == Enum.KeyCode.ButtonR2
				or input.KeyCode == Enum.KeyCode.ButtonL2
			then
				analog_values[input.KeyCode.Name] = input.Position
			end

			if input.UserInputType == Enum.UserInputType.MouseMovement then
				analog_values[input.UserInputType.Name] = input.Delta
			end
		end)
	)
end

function read_analog(input_name: string, deadzone: number?): Vector2
	deadzone = deadzone or default_deadzone

	local value = analog_values[input_name]
	if not value then
		return Vector2.new(0, 0)
	end

	if value.Magnitude < deadzone then
		return Vector2.new(0, 0)
	end

	return value
end

function pressed(input_name: string): boolean
	return states[input_name] == true and previous_states[input_name] ~= true
end

function down(input_name: string): boolean
	return states[input_name] == true
end

function released(input_name: string): boolean
	return states[input_name] ~= true and previous_states[input_name] == true
end

function up(input_name: string): boolean
	return states[input_name] ~= true
end

function disable(): ()
	enabled = false
end

function enable(): ()
	enabled = true
end

-- Reset analog values for mouse/controller if no movement detected (each frame)
local function reset_analog_if_idle()
	-- Mouse movement
	if analog_values["MouseMovement"] and analog_values["MouseMovement"].Magnitude ~= 0 then
		if
			not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
			and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
			and not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton3)
		then
			analog_values["MouseMovement"] = Vector2.zero
		end
	end
	-- Thumbsticks
	for _, key in { "Thumbstick1", "Thumbstick2" } do
		if analog_values[key] and analog_values[key].Magnitude ~= 0 then
			local found = false
			for _, input in ipairs(UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1)) do
				if input.KeyCode.Name == key and input.Position.Magnitude > 0 then
					found = true
					break
				end
			end
			if not found then
				analog_values[key] = Vector2.zero
			end
		end
	end
end

-- Patch update to also reset analog values
local old_update = update
function update()
	old_update()
	reset_analog_if_idle()
end

function update(): ()
	previous_states = table.clone(states)
end

function controls(): { string }
	local control_list = {}

	for key, _ in states do
		table.insert(control_list, key)
	end

	for key, _ in analog_values do
		if not table.find(control_list, key) then
			table.insert(control_list, key)
		end
	end

	return control_list
end

local function action(inputs: { Input }): Action
	return {
		pressed = function(): boolean
			for _, key in inputs do
				if pressed(key.Name) then
					return true
				end
			end
			return false
		end,
		down = function(): boolean
			for _, key in inputs do
				if down(key.Name) then
					return true
				end
			end
			return false
		end,
		released = function(): boolean
			for _, key in inputs do
				if released(key.Name) then
					return true
				end
			end
			return false
		end,
		up = function(): boolean
			for _, key in inputs do
				if up(key.Name) then
					return true
				end
			end
			return false
		end,
		read = function(_self, deadzone: number?): Vector2
			for _, key in inputs do
				local value = read_analog(key.Name, deadzone)
				if value.Magnitude > 0 then
					return value
				end
			end
			return Vector2.new(0, 0)
		end,
	}
end

function destroy(): ()
	for _, connection in connections do
		connection:Disconnect()
	end
	connections = {}
	states = {}
	previous_states = {}
	analog_values = {} :: InputStates<Vector2>
end

setup_connections()

return {
	action = action,
	read_analog = read_analog,

	pressed = pressed,
	released = released,
	down = down,
	up = up,

	disable = disable,
	enable = enable,

	update = update,
	controls = controls,
	states = states,
	destroy = destroy,
}
