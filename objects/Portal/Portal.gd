extends Area2D

class_name Portal

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var portal_sibling
var can_teleport = true

onready var teleportTimer = $TeleportTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_parent().get_children():
		if child.get_name() != get_name():
			portal_sibling = child


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func can_teleport():
	return can_teleport

func disable_teleport():
	can_teleport = false
	teleportTimer.start()

func _on_Portal_body_entered(body):
	if portal_sibling.can_teleport():
		print("Destination: %s" % portal_sibling.get_name())
		
		disable_teleport()
		
		body.global_position = portal_sibling.global_position
		
func _on_TeleportTimer_timeout():
	can_teleport = true
