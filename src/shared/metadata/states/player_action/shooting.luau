local Jecs = require("@jecs")
local components = require("@components")
local input_map = require(script.Parent.Parent.Parent.input_map)

local state_registry = require("@shared/utils/state_registry")

local enum = require("@shared/metadata/states/player_action/enum")
local action_transition = state_registry.create_transition("player_action")

return table.freeze({
	on_enter = function(world: Jecs.World, entity: Jecs.Entity)
		local camera = world:get(entity, components.Camera)
		local character = world:get(entity, components.Character)
		if not camera or character == nil then
			return
		end

		local lookVector = camera.CFrame.LookVector
		local origin = camera.CFrame.Position
		local target = origin + (lookVector * 100)

		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { character :: any }
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude

		local raycastResult = workspace:Raycast(origin, lookVector * 100, raycastParams)

		local debugLine = Instance.new("Part")
		debugLine.Size = Vector3.new(0.1, 0.1, (raycastResult and (raycastResult.Position - origin).Magnitude) or 100)
		debugLine.CFrame = CFrame.new(origin, target) * CFrame.new(0, 0, -debugLine.Size.Z / 2)
		debugLine.Anchored = true
		debugLine.CanCollide = false
		debugLine.BrickColor = BrickColor.new("Bright red")
		debugLine.Material = Enum.Material.Neon
		debugLine.Parent = workspace

		game:GetService("Debris"):AddItem(debugLine, 1)
	end,

	on_exit = function() end,

	update = function(world: Jecs.World, entity: Jecs.Entity, _dt: number)
		if input_map.shoot:released() then
			action_transition(world, entity, enum.IDLE)
		end
	end,
})
