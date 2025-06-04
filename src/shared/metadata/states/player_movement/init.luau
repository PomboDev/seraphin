local STATES_ENUM = require("@shared/metadata/states/player_movement/enum")

return table.freeze({
	[STATES_ENUM.IDLE] = require(script.idle),
	[STATES_ENUM.JUMPING] = require(script.jumping),
	[STATES_ENUM.WALKING] = require(script.walking),
	[STATES_ENUM.FALLING] = require(script.falling),
	[STATES_ENUM.SLIDING] = require(script.sliding),
	[STATES_ENUM.CROUCHING] = require(script.crouching),
})
