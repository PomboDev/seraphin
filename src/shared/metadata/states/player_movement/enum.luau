local STATES_ENUM = {
	IDLE = "idle",
	JUMPING = "jumping",
	FALLING = "falling",
	WALKING = "walking",
	CROUCHING = "crouching",
	SLIDING = "sliding",
	DASHING = "dashing",
	WALL_RUNNING = "wall_running",
}

return table.freeze(STATES_ENUM)
