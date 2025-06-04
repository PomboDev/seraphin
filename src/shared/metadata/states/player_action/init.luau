local STATES_ENUM = require("./enum")

return table.freeze({
	[STATES_ENUM.IDLE] = require(script.idle),
	[STATES_ENUM.SHOOTING] = require(script.shooting),
})
