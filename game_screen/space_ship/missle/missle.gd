extends Node2D

onready var direction
onready var time = get_node("Timer")
# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Fired").play()
	time.set_wait_time(10)
	time.start()
	pass # Replace with function body.

func set_direction(dir):
	direction = Vector2(0,0)
	direction.x = dir.x/100
	direction.y = dir.y/100
	
	var x = direction.y/direction.x
	if direction.x < 0:
		rotation_degrees = 180 + rad2deg(atan(x))
	else:
		rotation_degrees = rad2deg(atan(x))
		
	var hypothesis = sqrt((direction.x*direction.x)+(direction.y*direction.y))
	direction.x = (direction.x/hypothesis) * 6
	direction.y = (direction.y/hypothesis) * 6
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position += direction
	pass


func _on_Node2D_body_entered(body):
	if body.name == "Player" :
		Globals.update_gathered(-5,-5,-5,0,0,0)
	get_node("Sprite").visible = false
	get_node("CollisionShape2D").set_deferred("disabled", true)
	queue_free()
	pass # Replace with function body.


func _on_Timer_timeout():
	get_node("Sprite").visible = false
	get_node("CollisionShape2D").set_deferred("disabled", true)
	queue_free()
	pass # Replace with function body.
