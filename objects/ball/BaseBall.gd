extends KinematicBody2D

class_name BaseBall

enum Ownership {
	UNOWNED  = 0,
	PLAYER_1 = 1,
	PLAYER_2 = 2
}

# == Constants ==
const GRAVITY         = 500
const MAX_FALL_SPEED  = 1250
const DEAD_BALL_COUNT = 2
const MAX_BOUNCES     = 4
const DAMPENING       = 0.75
const MIN_VELOCITY    = 10

# == Member Variables ==
var ownership = Ownership.UNOWNED
var bounce_count = 0

var velocity = Vector2()

func set_velocity(new_velocity):
	velocity = new_velocity
	
func get_velocity():
	return velocity

func set_ownership(new_ownership):
	ownership = new_ownership
