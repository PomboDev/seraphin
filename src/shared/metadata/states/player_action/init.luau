local STATES_ENUM = require("@shared/metadata/states/player_action/enum")

return table.freeze({
	[STATES_ENUM.IDLE] = require(script.idle),
	[STATES_ENUM.SHOOTING] = require(script.shooting),
})
