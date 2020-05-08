extends Control

const DEFAULT_PORT = 8910 # An arbitrary number.

onready var address = $Address
onready var host_button = $HostButton
onready var join_button = $JoinButton
onready var status_ok = $StatusOk
onready var status_fail = $StatusFail

const LEVEL = preload("res://scenes/Online Level.tscn")

func _ready():
	# Connect all the callbacks related to networking.
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

#### Network callbacks from SceneTree ####

# Callback from SceneTree.
func _player_connected(_id):
	# Someone connected, start the game!
	var level = LEVEL.instance()
	# Connect deferred so we can safely erase it from the callback.
	level.connect("game_finished", self, "_end_game", [], CONNECT_DEFERRED)
	level.connect("game_reset", self, "_reset_game", [], CONNECT_DEFERRED)
	
	get_tree().get_root().add_child(level)
	hide()


func _player_disconnected(_id):
	if get_tree().is_network_server():
		_end_game("Client disconnected")
	else:
		_end_game("Server disconnected")


# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	pass # We don't need this function.


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	_set_status("Couldn't connect", false)
	
	get_tree().set_network_peer(null) # Remove peer.
	
	host_button.set_disabled(false)
	join_button.set_disabled(false)


func _server_disconnected():
	_end_game("Server disconnected")

##### Game creation functions ######

func _end_game(with_error = ""):
	if has_node("/root/World"):
		# Erase immediately, otherwise network might show errors (this is why we connected deferred above).
		get_node("/root/World").free()
		show()
	
	get_tree().set_network_peer(null) # Remove peer.
	host_button.set_disabled(false)
	join_button.set_disabled(false)
	
	_set_status(with_error, false)

func _reset_game(with_error = ""):
	if has_node("/root/World"):
		get_node("/root/World").free()
		
		var level = LEVEL.instance()
		# Connect deferred so we can safely erase it from the callback.
		level.connect("game_finished", self, "_end_game", [], CONNECT_DEFERRED)
		level.connect("game_reset", self, "_reset_game", [], CONNECT_DEFERRED)
	
		get_tree().get_root().add_child(level)

func _set_status(text, isok):
	# Simple way to show status.
	if isok:
		status_ok.set_text(text)
		status_fail.set_text("")
	else:
		status_ok.set_text("")
		status_fail.set_text(text)


func _on_online_pressed():
	get_tree().change_scene("res://scenes/menus/Lobby.tscn")


func _on_local_pressed():
	get_tree().change_scene("res://scenes/Local Level.tscn")
