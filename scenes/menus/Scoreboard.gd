extends Node

class_name Scoreboard

# Declare member variables here.
onready var PlayerScore1 = $PlayerScore1
onready var PlayerScore2 = $PlayerScore2

sync func set_scores(player_scores):
	PlayerScore1.text = str(player_scores[0])
	PlayerScore2.text = str(player_scores[1])

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
