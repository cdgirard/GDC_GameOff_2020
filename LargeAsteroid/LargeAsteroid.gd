extends StaticBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Globals.asteroid_direction = 0
	if Input.is_action_pressed("ui_right"):
		rotation_degrees += .5
		Globals.asteroid_motion = true
		Globals.asteroid_direction = 1
	elif Input.is_action_pressed("ui_left"):
		rotation_degrees -= .5
		Globals.asteroid_motion = true
		Globals.asteroid_direction = -1
