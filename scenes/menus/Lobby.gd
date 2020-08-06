extends Control

onready var address = $Address

onready var username = $Username
onready var username_label = $UsernameLabel
onready var abilitySelect = $AbilitySelect

onready var username2 = $Username2
onready var username_label2 = $UsernameLabel2
onready var abilitySelect2 = $AbilitySelect2

onready var host_button = $HostButton
onready var join_button = $JoinButton
onready var start_button = $StartButton
onready var start_online_button = $StartOnlineButton

onready var status_ok = $StatusOk
onready var status_fail = $StatusFail

const LEVEL = preload("res://scenes/Level.tscn")

func _ready():
	var _changed_lobby_status_error = Network.connect('changed_lobby_status', self, '_on_changed_lobby_status')
	var _can_start_error = Network.connect('can_start', self, '_on_can_start')
	
	for ability in GameVariables.abilities:
		abilitySelect.add_item(ability)
		abilitySelect2.add_item(ability)
	
	if GameVariables.local_play:
		# Show start button for local play
		start_button.visible = true
		
		# Hide host and join buttons for online play
		host_button.visible = false
		join_button.visible = false
		start_online_button.visible = false
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
		
		# Hide player 2 ability selector
		abilitySelect2.visible = false

##### Game creation functions ######
func _set_status(text, isok):
	# Simple way to show status.
	if isok:
		status_ok.set_text(text)
		status_fail.set_text("")
	else:
		status_ok.set_text("")
		status_fail.set_text(text)

func _on_host_pressed():
	host_button.set_disabled(true)
	join_button.set_disabled(true)
	
	start_online_button.visible = true
	start_online_button.set_disabled(true)
	
	_set_status("Waiting for other player...", true)
	
	var err = Network.create_server(str(username.text), str(abilitySelect.get_item_text(abilitySelect.selected)))
	
	if err != OK:
		# Is another server running?
		_set_status("Can't host, address in use.",false)
		return

func _on_join_pressed():
	host_button.set_disabled(true)
	join_button.set_disabled(true)
	
	var ip = address.get_text()
	
	if not ip.is_valid_ip_address():
		_set_status("IP address is invalid", false)
	
	Network.connect_to_server(str(username.text), str(abilitySelect.get_item_text(abilitySelect.selected)), ip)
	
	_set_status("Connecting...", true)

func _on_StartButton_pressed():
	var err = Network.start_offline_server()
	
	if err != OK:
		# Is another server running?
		_set_status("Can't host, address in use.",false)
		return
		
	GameVariables.players[0] = {'username': str(username.text), 'ability': str(abilitySelect.get_item_text(abilitySelect.selected))}
	GameVariables.players[1] = {'username': str(username2.text), 'ability': str(abilitySelect2.get_item_text(abilitySelect2.selected))}
		
	Network.start_online_game()

func _on_StartOnlineButton_pressed():
	start_online_button.set_disabled(true)
	
	Network.start_online_game()
	
func _on_changed_lobby_status(status, not_error):
	_set_status(status, not_error)

func _on_can_start():
	start_online_button.set_disabled(false)
