extends KinematicBody2D

class_name BasePlayer

# == Constants ==
const MOVE_SPEED     = 500
const JUMP_FORCE     = 1250
const GRAVITY        = 50
const MAX_FALL_SPEED = 1250

const BALL_VELOCITY  = 1000
const MAX_BALLS      = 2

# == Member Variables ==
var velocity = Vector2()
var facing_right = false
var is_jumping = false
var is_attacking = false

var can_shoot = true
var ball_count = 0

# Node References
onready var anim_player = $AnimationPlayer
onready var sprite = $Sprite
onready var throwTimer = $ThrowTimer
onready var ballPosition = $BallPosition2D

var ball_scene = preload("res://objects/ball/Ball.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
sync func _flip():
	facing_right = !facing_right
	sprite.scale.x = -sprite.scale.x
	ballPosition.position.x *= -1

sync func _attack(ball_player_id):
	var ball = ball_scene.instance()
	
	ball.global_position = ballPosition.global_position
	ball.set_ownership(ball_player_id)
	
	if facing_right:
		ball.set_velocity(Vector2(BALL_VELOCITY, 0))
	else:
		ball.set_velocity(Vector2(-BALL_VELOCITY, 0))
	
	get_parent().add_child(ball)
	
sync func _play_anim(anim_name):
	if anim_player.is_playing() and anim_player.current_animation == anim_name:
		return
	
	anim_player.play(anim_name)
	
func get_velocity():
	return velocity

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
