extends Node2D

onready var Star = preload("res://MainMenuScreen/Scenes/Star.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var star
# Called when the node enters the scene tree for the first time.
func _ready():
	_createStar(250,250,-1,1,3,-.05)
	_createStar(380,250,-1,1,3,-.05)
	_createStar(440,100,-1,1,2,-.03)
	_createStar(800,800,-1,1,4,-.1)
	_createStar(650,250,-1,1,1,-.01)
	_createStar(600,600,-1,1,2,-.03)
	
	pass # Replace with function body.

func _createStar(x,y,dirX,dirY,speed,rot):
	star = Star.instance()
	star.set_position(Vector2(x,y))
	star.setSpeedandDirection(dirX,dirY,speed,rot)
	add_child(star)
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass



func _on_Button3_pressed():
	get_tree().change_scene("res://MainMenuScreen/Scenes/Settings.tscn")
	pass


func _on_Button4_pressed():
	get_tree().change_scene("res://MainMenuScreen/Scenes/Credits.tscn")
	pass # Replace with function body.
