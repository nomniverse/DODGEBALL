extends Node

# == Preloading other scenes
const BALL = preload("res://objects/ball/Ball.tscn")

var ball_positions = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var i = 0
	
	for ball in get_children():
		ball_positions.append(ball.global_position)

func reset():
	for ball in get_children():
		ball.queue_free()
		
	for position in ball_positions:
		var ball = BALL.instance()
		add_child(ball)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
