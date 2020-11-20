extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var rng = RandomNumberGenerator.new();
	for n in range(10):
		var sprite = Sprite.new()
		sprite.texture = load("res://MainMenuScreen/star.png")
		var my_random_numberx = n * 1024/10
		print(my_random_numberx);
		var my_random_numbery = n * 600/10
		print(my_random_numbery);
		var position1 = Vector2(my_random_numberx,my_random_numbery)
		var scale1 = Vector2(.1,.1);
		sprite.set_scale(scale1);
		sprite.set_position(position1);
		add_child(sprite);
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

