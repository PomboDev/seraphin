local STATES_ENUM = require("./enum")

return table.freeze({
	[STATES_ENUM.IDLE] = require(script.idle),
	[STATES_ENUM.JUMPING] = require(script.jumping),
})
