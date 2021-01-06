extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	modulate.a = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += Vector2(0,-30.0*delta) #About 30 y per second
	
	if position.y > 300 and modulate.a < 1:
			modulate.a += 0.018
	if position.y < 70:
		modulate.a -= 0.018
	if position.y < 50:
		queue_free()
	pass
