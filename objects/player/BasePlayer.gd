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
var player_name = "Player"
var velocity = Vector2()
var facing_right = false
var is_jumping = false
var is_attacking = false

var can_shoot = true
var ball_count = 0

# Ability Variables
var ability = "invisible"

var using_ability = false
var ability_ready = true

# Node References
onready var anim_player = $AnimationPlayer
onready var sprite = $Sprite
onready var throwTimer = $ThrowTimer
onready var ballPosition = $BallPosition2D
onready var abilityDuration = $AbilityDuration
onready var abilityCooldown = $AbilityCooldown
onready var playerUsername = $PlayerUsername

var ball_scene = preload("res://objects/ball/Ball.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
sync func set_player_name(new_player_name):
	player_name = new_player_name
	playerUsername.text = player_name
	
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

func invisible(player_id):
	if get_tree().is_network_server():
		if player_id == 1:
			if sprite.modulate == Color(1, 1, 1):
				sprite.modulate = Color(0, 0, 1)
			else:
				sprite.modulate = Color(1, 1, 1)
		elif player_id == 2:
			sprite.visible = !sprite.visible
			playerUsername.visible = !playerUsername.visible
	else:
		if player_id == 1:
			sprite.visible = !sprite.visible
			playerUsername.visible = !playerUsername.visible
		elif player_id == 2:
			if sprite.modulate == Color(1, 1, 1):
				sprite.modulate = Color(0, 0, 1)
			else:
				sprite.modulate = Color(1, 1, 1)
			
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
