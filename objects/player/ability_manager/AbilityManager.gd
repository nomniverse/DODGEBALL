# Must be a direct child of a Player scene

extends Node2D

class_name AbilityManager

onready var durationTimer = $DurationTimer
onready var cooldownTimer = $CooldownTimer

var player

# Ability Variables
var ability = GameVariables.abilities[0]
var ability_ready = true

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent()
	ability = GameVariables.players[player.player_id - 1]['ability']
	
	if ability == 'Rewind':
		durationTimer.wait_time = 2

### Signal Events
func _on_DurationTimer_timeout():
	end_ability()
	player.can_shoot = true
	cooldownTimer.start()

func _on_CooldownTimer_timeout():
	ability_ready = true

### Class Functions
sync func use_ability():
	if ability_ready:
		player.can_shoot = false
		ability_ready = false
		durationTimer.start()
		call(ability, player.player_id, false)
	
func end_ability():
	call(ability, player.player_id, true)

### Abilities (function names should be uppercase)
func None(_player_id):
	pass
	
func Invisibility(player_id, _is_end):
	if not GameVariables.local_play:
		if get_tree().is_network_server():
			if player_id == 1:
				if player.sprite.modulate == Color(1, 1, 1):
					player.sprite.modulate = Color(0, 0, 1)
				else:
					player.sprite.modulate = Color(1, 1, 1)
			elif player_id == 2:
				player.sprite.visible = !player.sprite.visible
				player.playerUsername.visible = !player.playerUsername.visible
		else:
			if player_id == 1:
				player.sprite.visible = !player.sprite.visible
				player.playerUsername.visible = !player.playerUsername.visible
			elif player_id == 2:
				if player.sprite.modulate == Color(1, 1, 1):
					player.sprite.modulate = Color(0, 0, 1)
				else:
					player.sprite.modulate = Color(1, 1, 1)
	else:
		player.sprite.visible = !player.sprite.visible
		player.playerUsername.visible = !player.playerUsername.visible

var rewind_position

func Rewind(player_id, is_end):
	if is_end:
		player.position = rewind_position
	else:
		rewind_position = player.position
