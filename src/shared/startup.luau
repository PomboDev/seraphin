local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

local Jabby = require("@packages/jabby")
local scheduler = require("@std/scheduler")
local world = require("@world")

return function(systems: any)
	if #systems ~= 0 then
		scheduler:addSystems(systems)
	end

	if RunService:IsClient() then
		local client = Jabby.obtain_client()

		local function createWidget(_, state: Enum.UserInputState)
			if state ~= Enum.UserInputState.Begin then
				return
			end

			client.spawn_app(client.apps.home, nil)
		end

		ContextActionService:BindAction("Open Jabby", createWidget, false, Enum.KeyCode.F4)
	end

	Jabby.register({
		applet = Jabby.applets.world,
		name = "Jecs World",
		configuration = {
			world = world,
		},
	})
end
