extends BasePlayer

class_name Player

enum AnimationState {
	IDLE,
	WALK,
	JUMP
}

# == Export Variables ==
export var player_id : int = 1

# Variables
var _last_velocity = Vector2()
var _last_position = Vector2()
const LAST_POSITION_TOLERANCE = 2

var _last_animation_state = AnimationState.IDLE
var _animation_state = AnimationState.IDLE

var _last_move_dir = 0
var _last_is_attacking = false
var _last_is_jumping = false
var _last_using_ability = false

# == Puppet Variables ==
puppet var puppet_velocity = Vector2()
puppet var puppet_position = Vector2()
puppet var puppet_animation_state = AnimationState.IDLE

master var master_move_dir = 0
master var master_is_attacking = false
master var master_is_jumping = false
master var master_using_ability = false

# Way to identify class
func is_class(type): return type == "Player" or .is_class(type)
func    get_class(): return "Player"

# Called when the node enters the scene tree for the first time.
func _ready():
	_last_position = position
	
	set_player_name(GameVariables.players[player_id - 1]['username'])

func _physics_process(_delta):
	var move_dir = 0
	
	if GameVariables.local_play: master_move_dir = 0
	
	if not GameVariables.local_play:
		if Input.is_action_pressed("player_one_move_right"): move_dir += 1
		if Input.is_action_pressed("player_one_move_left"): move_dir -= 1
		
		is_jumping = Input.is_action_just_pressed("player_one_jump")
		is_attacking = Input.is_action_pressed("player_one_tag")
		using_ability = Input.is_action_just_pressed("player_one_ability")
	else:
		if player_id == 1:
			if Input.is_action_pressed("player_one_move_right"): move_dir += 1
			if Input.is_action_pressed("player_one_move_left"): move_dir -= 1
			
			is_jumping = Input.is_action_just_pressed("player_one_jump")
			is_attacking = Input.is_action_pressed("player_one_tag")
			using_ability = Input.is_action_just_pressed("player_one_ability")
		else:
			if Input.is_action_pressed("player_two_move_right"): master_move_dir += 1
			if Input.is_action_pressed("player_two_move_left"): master_move_dir -= 1
			
			master_is_jumping = Input.is_action_just_pressed("player_two_jump")
			master_is_attacking = Input.is_action_pressed("player_two_tag")
			master_using_ability = Input.is_action_just_pressed("player_two_ability")
	
	if is_network_master():
		if player_id == 1:
			velocity = Vector2(move_dir * MOVE_SPEED, velocity.y + GRAVITY)
		else:
			velocity = Vector2(master_move_dir * MOVE_SPEED, velocity.y + GRAVITY)
		
		var on_floor = is_on_floor()
		var on_ceiling = is_on_ceiling()
		
		if player_id == 1:
			if on_floor:
				if is_jumping: velocity.y = -JUMP_FORCE
			
				if velocity.y >= 5: velocity.y = 5
		else:
			if on_floor:
				if master_is_jumping: velocity.y = -JUMP_FORCE
			
				if velocity.y >= 5: velocity.y = 5
			
		if on_ceiling: velocity.y = 1
			
		if velocity.y > MAX_FALL_SPEED: velocity.y = MAX_FALL_SPEED
				
		if abs(_last_position.x - position.x) > LAST_POSITION_TOLERANCE or abs(_last_position.y - position.y) > LAST_POSITION_TOLERANCE:
			rset_unreliable("puppet_position", position)

			_last_position = position
			
		var _linear_velocity = move_and_slide(velocity, Vector2(0, -1))
	
		# Detect if you should be kicking a ball
		if ball_count == MAX_BALLS:
			for i in get_slide_count():
				var collision = get_slide_collision(i)
				
				if collision.collider is Ball: collision.collider.set_velocity(collision.collider.get_velocity() + velocity)
			
		if player_id == 1:
			if is_attacking and can_shoot and ball_count > 0:
				rpc("_attack", player_id)
				ball_count -= 1
		
				can_shoot = false
				throwTimer.start()
				
			if using_ability: get_node("AbilityManager").rpc("use_ability")
			
			if (facing_right and move_dir < 0) or (!facing_right and move_dir > 0): rpc("_flip")
				
			if is_on_floor():
				if move_dir == 0:
					_animation_state = AnimationState.IDLE
				else:
					_animation_state = AnimationState.WALK
			else:
				_animation_state = AnimationState.JUMP
		else:
			if master_is_attacking and can_shoot and ball_count > 0:
				rpc("_attack", player_id)
				ball_count -= 1
		
				can_shoot = false
				throwTimer.start()
				
			if master_using_ability: get_node("AbilityManager").rpc("use_ability")
			
			if (facing_right and master_move_dir < 0) or (!facing_right and master_move_dir > 0): rpc("_flip")
				
			if is_on_floor():
				if master_move_dir == 0:
					_animation_state = AnimationState.IDLE
				else:
					_animation_state = AnimationState.WALK
			else:
				_animation_state = AnimationState.JUMP
				
		if _last_animation_state != _animation_state:
			_last_animation_state = _animation_state
			
			if _animation_state == AnimationState.JUMP:
				rpc("_play_anim", "jump")
			elif _animation_state == AnimationState.WALK:
				rpc("_play_anim", "walk")
			else:
				rpc("_play_anim", "idle")
	else:
		if _last_move_dir != move_dir:
			rset("master_move_dir", move_dir)
			_last_move_dir = move_dir

		if _last_is_attacking != is_attacking:
			rset("master_is_attacking", is_attacking)
			_last_is_attacking = is_attacking

		if _last_is_jumping != is_jumping:
			rset("master_is_jumping", is_jumping)
			_last_is_jumping = is_jumping

		if _last_using_ability != using_ability:
			rset("master_using_ability", using_ability)
			_last_using_ability = using_ability

		position = puppet_position

func can_pick_up_ball():
	return ball_count + 1 <= MAX_BALLS
	
func get_ball_count():
	return ball_count
	
func set_ball_count(new_ball_count):
	ball_count = new_ball_count
	rset("puppet_ball_count", ball_count)
	
func tag():
	get_parent().rpc("reset_map")
	
func get_player_id():
	return player_id

func _on_ThrowTimer_timeout():
	can_shoot = true
