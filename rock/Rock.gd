extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_Rock_area_entered(area):
	if area.name == "PortalSensor" :
		Globals.contact_rock = true
		Globals.update_gathered(10,0,0)
		get_node("Explosion").emitting = true
		get_node("Sprite").visible = false
		get_node("CollisionShape2D").set_deferred("disabled", true)
