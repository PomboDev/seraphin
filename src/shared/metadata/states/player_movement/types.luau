local components = require("@components")

export type Context = {
	character: components.Character,
	humanoid: Humanoid,
	controller: components.CharacterController,
	ground_sensor: ControllerPartSensor,

	_jump_sustain_time: number,
	_jump_sustain_active: boolean,
}

return nil
