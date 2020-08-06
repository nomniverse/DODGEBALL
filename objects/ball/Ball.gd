extends BaseBall

class_name Ball

var _last_position = Vector2()
const LAST_POSITION_TOLERANCE = 2

puppet var puppet_position = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	_last_position = position
	
	if !is_network_master():
		puppet_position = position

func _physics_process(delta):
	if is_network_master():
		if not is_on_floor():
			velocity.y += GRAVITY * delta

			if velocity.y > GRAVITY: velocity.y = GRAVITY

		var collision = move_and_collide(velocity * delta)

		if abs(_last_position.x - position.x) > LAST_POSITION_TOLERANCE or abs(_last_position.y - position.y) > LAST_POSITION_TOLERANCE:
			rset_unreliable("puppet_position", position)
			
			_last_position = position

		if collision:
			#if collision.collider.get_name().begins_with("Player"):
			if collision.collider.is_class("Player"):
				velocity = velocity.bounce(collision.normal) + collision.collider.get_velocity()
			elif collision.collider.get_name().begins_with("Ball"):
				var old_velocity = velocity

				velocity = velocity.bounce(collision.normal) + collision.collider.get_velocity()
				collision.collider.set_velocity(collision.collider.get_velocity() + old_velocity)
			else:
				velocity = velocity.bounce(collision.normal)

			velocity *= Vector2(DAMPENING, DAMPENING)
			
			if abs(velocity.y) < MIN_VELOCITY: velocity.y = 0
				
			if abs(velocity.x) < MIN_VELOCITY: velocity.x = 0
			
			bounce_count += 1

			if bounce_count >= DEAD_BALL_COUNT:
				ownership = Ownership.UNOWNED
				bounce_count = 0
	else:
		position = puppet_position

sync func remove_ball():
	self.queue_free()

func _on_Hitbox_body_entered(body):
	if is_network_master():
		#if body.get_name().begins_with("Player"):
		if body.is_class("Player"):
			if ownership == Ownership.UNOWNED:
				if body.can_pick_up_ball():
					rpc("remove_ball")
					body.set_ball_count(body.get_ball_count() + 1)
				else:
					pass
			elif ownership != body.get_player_id():
				if bounce_count < DEAD_BALL_COUNT:
					get_parent().rpc("score", ownership)
					
					body.tag()
