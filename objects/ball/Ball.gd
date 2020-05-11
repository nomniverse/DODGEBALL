extends KinematicBody2D

class_name Ball

enum Ownership {
	UNOWNED  = 0,
	PLAYER_1 = 1,
	PLAYER_2 = 2
}

# == Constants ==
const GRAVITY        = 500
const MAX_FALL_SPEED = 1250
const DEAD_BALL_COUNT = 2
const MAX_BOUNCES = 4
const DAMPENING      = 0.75

# == Member Variables ==
var ownership = Ownership.UNOWNED
var bounce_count = 0

var velocity = Vector2()

func _physics_process(delta):

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
		if velocity.y > GRAVITY:
			velocity.y = GRAVITY
			
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		
		if collision.collider.get_name().begins_with("Player"):
			velocity = velocity.bounce(collision.normal) + collision.collider.get_velocity()
		elif collision.collider.get_name().begins_with("Ball"):
			var old_velocity = velocity
			
			velocity = velocity.bounce(collision.normal) + collision.collider.get_velocity()
			collision.collider.set_velocity(collision.collider.get_velocity() + old_velocity)
		else:
			velocity = velocity.bounce(collision.normal)
			
		velocity *= Vector2(DAMPENING, DAMPENING)
		
		bounce_count += 1
		
		if bounce_count >= DEAD_BALL_COUNT:
			ownership = Ownership.UNOWNED
			bounce_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_velocity(new_velocity):
	self.velocity = new_velocity
	
func get_velocity():
	return velocity

func set_ownership(new_ownership):
	self.ownership = new_ownership

func _on_Hitbox_body_entered(body):
	if body.get_name().begins_with("Player"):
		if ownership == Ownership.UNOWNED:
			if body.pick_up_ball():
				self.queue_free()
			else:
				pass
		elif ownership != body.get_player_id() and bounce_count < DEAD_BALL_COUNT:
			print("Tag! Point for Player %d" % ownership)
			#get_tree().reload_current_scene()
			
			body.tag()
			
			self.queue_free()
