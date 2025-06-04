local STATES_ENUM = {
	IDLE = "idle",
	JUMPING = "jumping",
	FALLING = "falling",
	WALKING = "walking",
	CROUCHING = "crouching",
	SLIDING = "sliding",
	DASHING = "dashing",
	WALL_SLIDING = "wall_running",
	WALL_RUNNING = "wall_running",
	WALL_JUMPING = "wall_jumping",
}

return table.freeze(STATES_ENUM)
