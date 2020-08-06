extends Node2D

onready var player1 = $Player1
onready var player2 = $Player2

onready var scoreboard = $Scoreboard

# Called when the node enters the scene tree for the first time.
func _ready():
	set_scores(GameVariables.player_scores)
	
func set_scores(player_scores):
	scoreboard.set_scores(player_scores)
	
sync func score(point_player):
	GameVariables.player_scores[point_player - 1] = GameVariables.player_scores[point_player - 1] + 1

func _on_exit_game_pressed():
	get_tree().set_network_peer(null) # Remove peer.
	var _error = get_tree().change_scene("res://scenes/menus/Start.tscn")

### Game State Functions
sync func reset_map():
	var _error = get_tree().reload_current_scene()
