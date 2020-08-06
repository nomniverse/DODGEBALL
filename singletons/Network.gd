extends Node

signal changed_lobby_status(status, not_error)
signal can_start()

const DEFAULT_PORT = 8910 # An arbitrary number.

const LEVEL = preload("res://scenes/Level.tscn")
const PLAYER = preload("res://objects/player/Player.tscn")

var self_data = { username = '', ability = ''} # Holds data temporarily

# Called when the node enters the scene tree for the first time.
func _ready():
	### Connect all the callbacks related to networking.
	# Server callbacks
	var _network_peer_connected_error = get_tree().connect("network_peer_connected", self, "_player_connected")
	var _network_peer_disconnected_error = get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	# Client callbacks
	var _connected_to_server_error = get_tree().connect("connected_to_server", self, "_connected_ok")
	var _connection_failed_error = get_tree().connect("connection_failed", self, "_connected_fail")
	var _server_disconnected_error = get_tree().connect("server_disconnected", self, "_server_disconnected")

#### Network callbacks from SceneTree ####
func _player_connected(_id):
	# Get info from the server
	if get_tree().is_network_server():
		rpc_id(_id, 'send_player_info', 1, self_data)
		emit_signal('changed_lobby_status', "Client connected!", true)
		emit_signal('can_start')
	else:
		rpc_id(_id, 'send_player_info', 2, self_data)
		emit_signal('changed_lobby_status', "Server connected!", true)

# Callback from SceneTree.
func _player_disconnected(_id):
	if get_tree().is_network_server():
		_end_game("Client disconnected")
	else:
		_end_game("Server disconnected")

# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	rpc('send_player_info', 2, self_data)

# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	emit_signal('changed_lobby_status', "Couldn't connect", false)
	
	get_tree().set_network_peer(null) # Remove peer.
	
	#host_button.set_disabled(false)
	#join_button.set_disabled(false)

func _server_disconnected():
	_end_game("Server disconnected")

#### Class Functions
# Creates a host server locally
func create_server(playername, ability, port=DEFAULT_PORT):
	self_data.username = playername
	self_data.ability = ability
	GameVariables.players[0] = self_data
	
	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	var err = host.create_server(port, 1) # Maximum of 1 peer, since it's a 2-player game.
	
	if err != OK:
		# Is another server running?
		return
	
	get_tree().set_network_peer(host)
	
	return err
	
# Connects to a host server at a specific address
func connect_to_server(playername, ability, address, port=DEFAULT_PORT):
	self_data.username = playername
	self_data.ability = ability
	GameVariables.players[1] = self_data
	
	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	host.create_client(address, port)
	get_tree().set_network_peer(host)

func start_offline_server(port=DEFAULT_PORT):
	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	var err = host.create_server(port, 1) # Maximum of 1 peer, since it's a 2-player game.
	
	if err != OK:
		return err
	
	get_tree().set_network_peer(host)

	return err

func start_online_game():
	rpc("go_to_level")

func _end_game(message):
	get_tree().set_network_peer(null) # Remove peer.
	
	print(message)
	
	var _error = get_tree().change_scene("res://scenes/menus/Start.tscn")
	
	#emit_signal('changed_lobby_status', message, false)

sync func go_to_level():
	var _error = get_tree().change_scene("res://scenes/Level.tscn")

### === Username Handling ===
remote func send_player_info(id, info):
	GameVariables.players[id - 1] = info
