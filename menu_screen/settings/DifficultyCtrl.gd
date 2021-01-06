extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


#Value ranges from -4 easy, to -1 nightmare, change to positive
#for resource multiplier
func _on_DiffSlider_value_changed(value):
	Globals.difficulty = abs(value)
