extends Control

func _on_online_pressed():
	var _error = get_tree().change_scene("res://scenes/menus/Lobby.tscn")

func _on_local_pressed():
	var _error = get_tree().change_scene("res://scenes/Local Level.tscn")
