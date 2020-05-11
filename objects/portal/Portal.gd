extends Area2D

class_name Portal

onready var teleportTimer = $TeleportTimer

var portal_sibling
var teleportable = true

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_parent().get_children():
		if child.get_name() != get_name():
			portal_sibling = child

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func is_teleportable():
	return teleportable

func disable_teleport():
	teleportable = false
	teleportTimer.start()

func _on_Portal_body_entered(body):
	if portal_sibling.is_teleportable():
		disable_teleport()
		
		body.global_position = portal_sibling.global_position
		
func _on_TeleportTimer_timeout():
	teleportable = true
