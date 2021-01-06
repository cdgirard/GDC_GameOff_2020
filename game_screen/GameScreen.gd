extends Node2D

onready var Background = preload("res://game_screen/game_background/GameBackground.tscn")
onready var GameScreenUI = preload("res://game_screen/ui/GameScreenUI.tscn")
onready var Ship = preload("res://game_screen/space_ship/Spaceship.tscn")
onready var MotherShip = preload("res://game_screen/mother_ship/mother_ship.tscn")

var rock_num = 0
var boost_timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Universe.init_universe(self)
	add_child(Background.instance())
	add_child(Universe.player)
	add_child(GameScreenUI.instance())
	#May need to be moved.
	Universe.determine_gravity_source()
	#var s = Ship.instance()
	#s.createEntity(1,Vector2(Universe.player.global_position.x-500,Universe.player.global_position.y))
	add_child(MotherShip.instance())
	if Globals.play_start :
		Globals.activate_display_thought(Globals.start_text)
	#add_child(s)

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Universe.player != null and Globals.asteroid_search :
		Universe.determine_gravity_source()
	if Universe.player != null and Universe.player.in_orbit :
		remove_child(Universe.player)
		Universe.player = null
	if Globals.game_end and not Globals.display_thought :
		Globals.active_camera.current = false
		get_tree().change_scene("res://menu_screen/MenuScreen.tscn")
#	var count = 0
#	if Input.is_action_pressed("ui_up"):
#		print("Up")
#		for pos in asteroids :
#			if count == rock_num :
#				Globals.active_asteroid = asteroids[pos]
#				rock_num += 1
#				rock_num = rock_num % asteroids.size()
#				break
#			count += 1
	
#	pass
