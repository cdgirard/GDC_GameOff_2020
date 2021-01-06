extends Path2D


# Declare member variables here. Examples:
export var planet_speed = 0.01
export var moon_speed = 0.05


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	$Planet.set_unit_offset($Planet.get_unit_offset()+planet_speed*delta)
	if $Planet/MoonPath/Moon.get_child_count() > 0:
		$Planet/MoonPath/Moon.set_unit_offset($Planet/MoonPath/Moon.get_unit_offset()+moon_speed*delta)
