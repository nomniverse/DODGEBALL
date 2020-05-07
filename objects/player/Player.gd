extends KinematicBody2D

class_name Player

enum State {
	ALIVE,
	DEAD
}

# == Constants ==
const MOVE_SPEED     = 500
const JUMP_FORCE     = 1250
const GRAVITY        = 50
const MAX_FALL_SPEED = 1250

const BALL_VELOCITY  = 1000
const MAX_BALLS      = 2

export var player_id : int = 1

# == Node References ==
onready var anim_player = $AnimationPlayer
onready var sprite = $Sprite
onready var throwTimer = $ThrowTimer
onready var ballPosition = $BallPosition2D

# == Member Variables ==
var velocity = Vector2()
var facing_right = false
var is_jumping = false
var is_attacking = false

var can_shoot = true
var ball_count = 0

var original_position

# == Preloading other scenes
const BALL = preload("res://objects/ball/Ball.tscn")

func _physics_process(delta):
	var move_dir = 0
	
	if player_id == 1:
		if Input.is_action_pressed("player_one_move_right"):
			move_dir += 1
		if Input.is_action_pressed("player_one_move_left"):
			move_dir -= 1
		
		is_jumping = Input.is_action_just_pressed("player_one_jump")
		
		is_attacking = Input.is_action_pressed("player_one_tag")
	elif player_id == 2:
		if Input.is_action_pressed("player_two_move_right"):
			move_dir += 1
		if Input.is_action_pressed("player_two_move_left"):
			move_dir -= 1
		
		is_jumping = Input.is_action_just_pressed("player_two_jump")
		
		is_attacking = Input.is_action_pressed("player_two_tag")
	else:
		pass
		
	velocity.x = move_dir * MOVE_SPEED
   
	var grounded = is_on_floor()
	
	velocity.y += GRAVITY
	
	if grounded and is_jumping:
		velocity.y = -JUMP_FORCE
	if grounded and velocity.y >= 5:
		velocity.y = 5
	if velocity.y > MAX_FALL_SPEED:
		velocity.y = MAX_FALL_SPEED
		
	move_and_slide(velocity, Vector2(0, -1))
   
	if (facing_right and move_dir < 0) or (!facing_right and move_dir > 0):
			flip()

	if grounded:
		if move_dir == 0:
			play_anim("idle")
		else:
			play_anim("walk")
	else:
		play_anim("jump")
		
	if is_attacking and can_shoot and ball_count > 0:
		var ball = BALL.instance()
		
		ball.global_position = ballPosition.global_position
		ball.set_ownership(player_id)
		
		if facing_right:
			ball.set_velocity(Vector2(BALL_VELOCITY, 0))
		else:
			ball.set_velocity(Vector2(-BALL_VELOCITY, 0))
		
		get_parent().add_child(ball)
		
		ball_count -= 1
		
		can_shoot = false
		throwTimer.start()
 
func flip():
	facing_right = !facing_right
	sprite.scale.x = -sprite.scale.x
	ballPosition.position.x *= -1
	
func get_player_id():
	return player_id
	
func pick_up_ball():
	if ball_count + 1 <= MAX_BALLS:
		ball_count += 1
		return true
	else:
		return false
		
func get_velocity():
	return velocity
 
func play_anim(anim_name):
	if anim_player.is_playing() and anim_player.current_animation == anim_name:
		return
	
	anim_player.play(anim_name)
	
func reset():
	global_position = original_position
	var facing_right = false
	var is_jumping = false
	var is_attacking = false
	
	var can_shoot = true
	var ball_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	original_position = global_position
	
func tag():
	get_tree().reload_current_scene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_ThrowTimer_timeout():
	can_shoot = true
