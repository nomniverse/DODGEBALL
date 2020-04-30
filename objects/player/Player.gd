extends KinematicBody2D

# == Constants ==
const MOVE_SPEED     = 500
const JUMP_FORCE     = 1000
const GRAVITY        = 50
const MAX_FALL_SPEED = 1000

export var player_id : int = 0

# == Node References ==
onready var anim_player = $AnimationPlayer
onready var sprite = $Sprite

# == Member Variables ==
var y_velo = 0
var facing_right = false
var is_jumping = false
var is_attacking = false

func _physics_process(delta):
	var move_dir = 0
	
	if player_id == 0:
		if Input.is_action_pressed("player_one_move_right"):
			move_dir += 1
		if Input.is_action_pressed("player_one_move_left"):
			move_dir -= 1
		
		is_jumping = Input.is_action_just_pressed("player_one_jump")
		
		is_attacking = Input.is_action_pressed("player_one_tag")
	elif player_id == 1:
		if Input.is_action_pressed("player_two_move_right"):
			move_dir += 1
		if Input.is_action_pressed("player_two_move_left"):
			move_dir -= 1
		
		is_jumping = Input.is_action_just_pressed("player_two_jump")
		
		is_attacking = Input.is_action_pressed("player_two_tag")
	else:
		pass
		
	move_and_slide(Vector2(move_dir * MOVE_SPEED, y_velo), Vector2(0, -1))
   
	var grounded = is_on_floor()
	
	y_velo += GRAVITY
	
	if grounded and is_jumping:
		y_velo = -JUMP_FORCE
	if grounded and y_velo >= 5:
		y_velo = 5
	if y_velo > MAX_FALL_SPEED:
		y_velo = MAX_FALL_SPEED
   
	if facing_right and move_dir < 0:
		flip()
	if !facing_right and move_dir > 0:
		flip()

	if grounded:
		if is_attacking:
			play_anim("attack")
			is_attacking = false
		else:
			if move_dir == 0:
				play_anim("idle")
			else:
				play_anim("walk")
	else:
		play_anim("jump")
 
func flip():
	facing_right = !facing_right
	sprite.scale.x = -sprite.scale.x
 
func play_anim(anim_name):
	if anim_player.is_playing() and anim_player.current_animation == anim_name:
		return
	
	anim_player.play(anim_name)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_TagHit_body_entered(body):
	if not body.get_name() == self.get_name():
		if body.get_name().begins_with("Player"):
			print("Tag! You're whatever we do with this...")
	
		
