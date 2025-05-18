local STATES_ENUM = require("./enum")

return table.freeze({
	[STATES_ENUM.IDLE] = require(script.idle),
	[STATES_ENUM.JUMPING] = require(script.jumping),
	[STATES_ENUM.WALKING] = require(script.walking),
	[STATES_ENUM.FALLING] = require(script.falling),
	[STATES_ENUM.CROUCHING] = require(script.crouching),
	[STATES_ENUM.SLIDING] = require(script.sliding),
})
