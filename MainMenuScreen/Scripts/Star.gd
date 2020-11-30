extends Node2D


var speed = 1;
var xDir = 1;
var yDir = 1;
var rotationAng = 0;
onready var Trail = preload("res://MainMenuScreen/Scenes/Trail.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	position += Vector2(xDir*speed, yDir*speed);
	if position.x > 1024:
		position.x = 0
	if position.y > 600:
		position.y = 0
	if position.x < 0:
		position.x = 1024
	if position.y < 0:
		position.y = 600
	$Sprite.rotation += rotationAng
	pass
	
func setSpeedandDirection(x,y,speeds,rot):
	xDir = x
	yDir = y
	speed = speeds
	rotationAng = rot
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
