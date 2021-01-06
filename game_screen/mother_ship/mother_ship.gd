extends Node2D

onready var time = get_node("Timer")
onready var Ship = preload("res://game_screen/space_ship/Spaceship.tscn")
var rng = RandomNumberGenerator.new()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	time.set_wait_time(rng.randf_range(10.0, 25.0))
	time.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass


func _on_Timer_timeout():
	time.stop()
	var s = Ship.instance()
	if Globals.active_asteroid.global_position.x < Universe.player.global_position.x:
		if Globals.active_asteroid.global_position.y < Universe.player.global_position.y:
			s.createEntity(-1,Vector2(Universe.player.global_position.x + (700 * Universe.player.get_node("Camera2D").zoom.x),Universe.player.global_position.y + 200))
		else: 
			s.createEntity(-1,Vector2(Universe.player.global_position.x + (700 * Universe.player.get_node("Camera2D").zoom.x),Universe.player.global_position.y - 200))
	else:
		if Globals.active_asteroid.global_position.y < Universe.player.global_position.y:
			s.createEntity(-1,Vector2(Universe.player.global_position.x + (700 * Universe.player.get_node("Camera2D").zoom.x),Universe.player.global_position.y + 200))
		else:
			s.createEntity(1,Vector2(Universe.player.global_position.x - (700 * Universe.player.get_node("Camera2D").zoom.x),Universe.player.global_position.y - 200))
	add_child(s)
	time.set_wait_time(rng.randf_range(10.0, 25.0))
	time.start()
	pass # Replace with function body.
