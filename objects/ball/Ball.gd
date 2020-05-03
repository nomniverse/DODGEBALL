extends RigidBody2D

class_name Ball

enum Ownership {
	UNOWNED  = 0,
	PLAYER_1 = 1,
	PLAYER_2 = 2
}

const DEAD_BALL_COUNT = 1

var ownership = Ownership.UNOWNED

var bounce_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_ownership(ownership):
	self.ownership = ownership

func _on_Ball_body_entered(body):
	if body.get_name().begins_with("Player"):
		if ownership == Ownership.UNOWNED:
			body.pick_up_ball()
			self.queue_free()
		elif ownership != body.get_player_id() and bounce_count < DEAD_BALL_COUNT:
			print("Tag!")
			get_tree().reload_current_scene()
			self.queue_free()
	else:
		bounce_count += 1
		
		if bounce_count >= DEAD_BALL_COUNT:
			ownership = Ownership.UNOWNED
