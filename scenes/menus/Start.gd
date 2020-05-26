extends Control

func _on_online_pressed():
	GameVariables.local_play = false
	
	var _error = get_tree().change_scene("res://scenes/menus/Lobby.tscn")

func _on_local_pressed():
	GameVariables.local_play = true
	
	var _error = get_tree().change_scene("res://scenes/menus/Lobby.tscn")
