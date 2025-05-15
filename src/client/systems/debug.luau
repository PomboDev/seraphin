local Jecs = require("@jecs")
local PlanckRunService = require("@packages/planck-runservice")

local components = require("@components")
local Phases = PlanckRunService.Phases

local debugGui

local function createDebugGui(): any
	if debugGui then
		return debugGui
	end

	debugGui = Instance.new("ScreenGui")
	debugGui.Name = "DebugGui"
	debugGui.ResetOnSpawn = false

	local frame = Instance.new("Frame")
	frame.Name = "DebugFrame"
	frame.Size = UDim2.new(0.3, 0, 0.5, 0)
	frame.Position = UDim2.new(0, 10, 0, 10)
	frame.BackgroundTransparency = 0.5
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BorderSizePixel = 0
	frame.Parent = debugGui

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "DebugText"
	textLabel.Size = UDim2.new(1, -10, 1, -10)
	textLabel.Position = UDim2.new(0, 5, 0, 5)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Top
	textLabel.Font = Enum.Font.Code
	textLabel.TextSize = 14
	textLabel.Text = ""
	textLabel.Parent = frame

	debugGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	return debugGui
end

local function debug_system(world: Jecs.World)
	local gui = createDebugGui()
	local debugText = gui.DebugFrame.DebugText

	local debugInfo = {}

	-- Collect debug information
	for id, character, state_machines in world:query(components.Character, components.StateMachines) do
		table.insert(debugInfo, `Entity Id: {id}`)
		table.insert(debugInfo, ``)

		table.insert(debugInfo, `[CHARACTER]`)
		local velocity = character.HumanoidRootPart.AssemblyLinearVelocity
		table.insert(debugInfo, `  Move Direction: {character.Humanoid.MoveDirection}`)
		table.insert(debugInfo, `  Acceleration: {string.format("%.2f", velocity.Magnitude)}`)
		table.insert(debugInfo, `  Is Grounded: {character.HumanoidRootPart.ControllerPartSensor.SensedPart ~= nil}`)
		table.insert(debugInfo, `  Humanoid State: {character.Humanoid:GetState()}`)

		table.insert(debugInfo, `[STATE MACHINES]`)
		for state_group, state_machine in state_machines do
			local _s, functions = next(state_group)
			local str = debug.info(functions.update :: () -> nil, "s")
			local path = string.match(str, "%.states%.([^.]+)")
			table.insert(debugInfo, `\t{path}`)
			table.insert(debugInfo, `\t\tCurrent State: {state_machine.current}`)
			table.insert(debugInfo, `\t\tPrevious State: {state_machine.previous or "None"}`)
		end

		table.insert(debugInfo, "")
	end

	-- Update the debug text
	debugText.Text = table.concat(debugInfo, "\n")
end

return {
	system = debug_system,
	phase = Phases.PostSimulation,
}
