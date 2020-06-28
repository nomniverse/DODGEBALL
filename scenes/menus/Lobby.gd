extends Control

const DEFAULT_PORT = 8910 # An arbitrary number.

onready var address = $Address

onready var username = $Username
onready var username_label = $UsernameLabel
onready var username2 = $Username2
onready var username_label2 = $UsernameLabel2

onready var player_scores = [0, 0]

onready var host_button = $HostButton
onready var join_button = $JoinButton
onready var start_button = $StartButton

onready var status_ok = $StatusOk
onready var status_fail = $StatusFail

const LEVEL = preload("res://scenes/Level.tscn")

func _ready():
	if GameVariables.local_play:
		# Show start button for local play
		start_button.visible = true
		
		# Hide host and join buttons for online play
		host_button.visible = false
		join_button.visible = false
	else:
		# Hide start button for local play
		start_button.visible = false
		
		# Show host and join buttons for online play
		host_button.visible = true
		join_button.visible = true
		
		# Change the naming fields
		username_label.text = "Username"
		username2.visible = false
		username_label2.visible = false
		
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
	_load_level()
	
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
		
	_load_level()
	
func _update_score(point_player):
	if point_player == 1:
		player_scores[0] = player_scores[0] + 1
	else:
		player_scores[1] = player_scores[1] + 1

func _set_status(text, isok):
	# Simple way to show status.
	if isok:
		status_ok.set_text(text)
		status_fail.set_text("")
	else:
		status_ok.set_text("")
		status_fail.set_text(text)

func _on_host_pressed():
	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	var err = host.create_server(DEFAULT_PORT, 1) # Maximum of 1 peer, since it's a 2-player game.
	if err != OK:
		# Is another server running?
		_set_status("Can't host, address in use.",false)
		return
	
	get_tree().set_network_peer(host)
	host_button.set_disabled(true)
	join_button.set_disabled(true)
	_set_status("Waiting for other player...", true)


func _on_join_pressed():
	var ip = address.get_text()
	if not ip.is_valid_ip_address():
		_set_status("IP address is invalid", false)
		return
	
	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	host.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(host)
	
	_set_status("Connecting...", true)


func _load_level():
	var level = LEVEL.instance()
	# Connect deferred so we can safely erase it from the callback.
	level.connect("game_finished", self, "_end_game", [], CONNECT_DEFERRED)
	level.connect("game_reset", self, "_reset_game", [], CONNECT_DEFERRED)
	level.connect("update_score", self, "_update_score", [], CONNECT_DEFERRED)
	
	level.set_self_player_name(username.text)
	
	get_tree().get_root().add_child(level)
	
	level.set_scores(player_scores)


func _on_StartButton_pressed():
	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	var err = host.create_server(DEFAULT_PORT, 1) # Maximum of 1 peer, since it's a 2-player game.
	if err != OK:
		# Is another server running?
		_set_status("Can't host, address in use.",false)
		return
	
	get_tree().set_network_peer(host)
	
	var level = LEVEL.instance()
	# Connect deferred so we can safely erase it from the callback.
	level.connect("game_finished", self, "_end_game", [], CONNECT_DEFERRED)
	level.connect("game_reset", self, "_reset_game", [], CONNECT_DEFERRED)
	level.connect("update_score", self, "_update_score", [], CONNECT_DEFERRED)
	
	get_tree().get_root().add_child(level)
	
	level.set_player_one_name(username.text)
	level.set_player_two_name(username2.text)
	
	level.set_scores(player_scores)

	hide()
