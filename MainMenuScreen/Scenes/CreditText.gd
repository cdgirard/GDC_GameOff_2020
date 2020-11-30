extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	modulate.a = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += Vector2(0,-1)
	
	if position.y > 390:
		if position.y < 400:
			modulate.a += 0.1
	if position.y < 60:
		modulate.a -= 0.1
	if position.y < 50:
		queue_free()
	pass
