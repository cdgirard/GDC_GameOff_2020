extends Sprite


# Declare member variables here.


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Universe.player != null :
		var adjusted = Vector2(Universe.player.global_position.x,Universe.player.global_position.y)
		var player_unit_vec = adjusted.normalized()
		var angle = player_unit_vec.angle()
		angle = rad2deg(angle)
		rotation_degrees = angle - 90

