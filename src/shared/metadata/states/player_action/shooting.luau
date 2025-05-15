local Jecs = require("@jecs")
local _components = require("@components")
local input_map = require(script.Parent.Parent.Parent.input_map)
local noop = require("@std/noop")

local state_registry = require("@shared/utils/state_registry")

local enum = require("@shared/metadata/states/player_action/enum")
local types = require("@shared/metadata/states/player_action/types")
local action_transition = state_registry.create_transition("player_action")

return table.freeze({
	on_enter = function(_world: Jecs.World, _entity: Jecs.Entity, context: types.Context)
		local lookVector = context.camera.CFrame.LookVector
		local origin = context.camera.CFrame.Position
		local target = origin + (lookVector * 100)

		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { context.character :: any }
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

	on_exit = noop,

	update = function(world: Jecs.World, entity: Jecs.Entity, context: types.Context)
		if input_map.shoot:released() then
			action_transition(world, entity, context, enum.IDLE)
		end
	end,
})
