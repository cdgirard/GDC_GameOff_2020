extends Node2D

onready var Background = preload("res://game_background/GameBackground.tscn")
onready var Player = preload("res://player/Player.tscn")
onready var LargeAsteroid = preload("res://LargeAsteroid/LargeAsteroid.tscn")
onready var GameScreenUI = preload("res://GameScreenUI.tscn")

var universeSprite = Sprite.new()
var asteroids = {}
var player
var rock_num = 0
var boost_timer = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	var bkg = Background.instance()
	add_child(bkg)
	universeSprite.texture = load("res://universe/universe_map.png")
	create_map()
	player = Player.instance()
	player.position.y = -400
	add_child(player)
	add_child(GameScreenUI.instance())
	determine_gravity_source()

func determine_gravity_source() :
	var min_dist = -1
	for pos in asteroids :
		var dist = (pos - player.position).length()
		if min_dist == -1 :
			min_dist = dist
			Globals.active_asteroid = asteroids[pos]
		elif min_dist > dist :
			min_dist = dist
			Globals.active_asteroid = asteroids[pos]

func create_map() :
	var info = universeSprite.texture.get_data()
	info.lock()
	var row = 0
	
	while row < info.get_height() :
		var col = 0
		while col < info.get_width() :
			var blockLoc = Vector2(800*col,800*row)
			var colorInfo = info.get_pixel(col,row)
			var asteroid = null
			if colorInfo.r == 0 and colorInfo.g == 0 and colorInfo.b == 0 : #black
				asteroid = LargeAsteroid.instance()
			if colorInfo.r == 1 and colorInfo.g == 0 and colorInfo.b == 0 : #red
				asteroid = LargeAsteroid.instance()
			if colorInfo.r == 0 and colorInfo.g == 1 and colorInfo.b == 0 : #green
				asteroid = LargeAsteroid.instance()
			if colorInfo.r == 0 and colorInfo.g == 0 and colorInfo.b == 1 : #blue
				asteroid = LargeAsteroid.instance()
			if colorInfo.r == 1 and colorInfo.g == 0 and colorInfo.b == 1 : #purple
				asteroid = LargeAsteroid.instance()
			if colorInfo.r == 0 and colorInfo.g == 1 and colorInfo.b == 1 : #Blue Green
				asteroid = LargeAsteroid.instance()
			if asteroid != null :
					asteroid.position = blockLoc
					asteroids[asteroid.position] = asteroid
					add_child(asteroid)
			col += 1
		row += 1
	info.unlock()
	

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.asteroid_search :
		determine_gravity_source()
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
