extends Node2D

onready var Star = preload("res://menu_screen/Star.tscn")

var star

# Called when the node enters the scene tree for the first time.
func _ready():
	$Camera2D.current = true
	_createStar(250,250,-1,1,3,-.05)
	_createStar(380,250,-1,1,3,-.05)
	_createStar(440,100,-1,1,2,-.03)
	_createStar(800,800,-1,1,4,-.1)
	_createStar(650,250,-1,1,1,-.01)
	_createStar(600,600,-1,1,2,-.03)

	# Play main menu music
	if !MusicPlayer.is_track_playing(0):
		MusicPlayer.track_play(MusicPlayer.bgm_main_menu, 0)
	
	
	pass # Replace with function body.

func _createStar(x,y,dirX,dirY,speed,rot):
	star = Star.instance()
	star.set_position(Vector2(x,y))
	star.setSpeedandDirection(dirX,dirY,speed,rot)
	add_child(star)

func _on_Button3_pressed():
	var _success = get_tree().change_scene("res://menu_screen/settings/Settings.tscn")

func _on_Button4_pressed():
	var _success = get_tree().change_scene("res://menu_screen/credits/Credits.tscn")
