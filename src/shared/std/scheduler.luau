local Planck = require("@packages/planck")
local Scheduler = Planck.Scheduler

local world = require("@world")

local PlanckJabby = require("@packages/planck-jabby")
local jabbyPlugin = PlanckJabby.new()

local PlanckRunService = require("@packages/planck-runservice")
local runServicePlugin = PlanckRunService.Plugin.new()

local scheduler = Scheduler.new(world):addPlugin(jabbyPlugin :: any):addPlugin(runServicePlugin :: any)

return scheduler
