local components = require("@components")

export type Context = {
	humanoid: Humanoid,
	root_part: BasePart,
	character: components.Character,
	controller: components.CharacterController,
	climbing_sensor: ControllerPartSensor,
	ground_sensor: ControllerPartSensor,

	jump_force: number,
	jump_buffer: number,
	jump_cooldown: number,
	coyote_time: number,

	acceleration: number,
	deceleration: number,
	friction: number,
	friction_weight: number,

	speed: number,
	turn_speed: number,
	slope_angle: number,
}

return nil
