extends Node2D

signal game_finished()
signal game_reset()

onready var player1 = $Player1
onready var player2 = $Player2

var player_name = "Player"

# Called when the node enters the scene tree for the first time.
func _ready():
	# By default, all nodes in server inherit from master,
	# while all nodes in clients inherit from puppet.
	# set_network_master is tree-recursive by default.
	if get_tree().is_network_server():
		rpc("set_player_one_name", player_name)
	else:
		rpc("set_player_two_name", player_name)
	
#	if get_tree().is_network_server():
#		# For the server, give control of player 2 to the other peer. 
#		player2.set_network_master(get_tree().get_network_connected_peers()[0])
#	else:
#		# For the client, give control of player 2 to itself.
#		player2.set_network_master(get_tree().get_network_unique_id())
#	print("unique id: ", get_tree().get_network_unique_id())

func set_self_player_name(new_player_name):
	player_name = new_player_name

sync func set_player_one_name(player_one_name):
	player1.set_player_name(player_one_name)
	
sync func set_player_two_name(player_two_name):
	player2.set_player_name(player_two_name)

sync func reset_map():
	emit_signal("game_reset")

func _on_exit_game_pressed():
	emit_signal("game_finished")
