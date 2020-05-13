extends Node2D

signal game_finished()
signal game_reset()

onready var player2 = $Player2

# Called when the node enters the scene tree for the first time.
func _ready():
	# By default, all nodes in server inherit from master,
	# while all nodes in clients inherit from puppet.
	# set_network_master is tree-recursive by default.
	pass
	
#	if get_tree().is_network_server():
#		# For the server, give control of player 2 to the other peer. 
#		player2.set_network_master(get_tree().get_network_connected_peers()[0])
#	else:
#		# For the client, give control of player 2 to itself.
#		player2.set_network_master(get_tree().get_network_unique_id())
#	print("unique id: ", get_tree().get_network_unique_id())

sync func reset_map():
	emit_signal("game_reset")

func _on_exit_game_pressed():
	emit_signal("game_finished")
