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
	Globals.starting = true
	var bkg = Background.instance()
	add_child(bkg)
	universeSprite.texture = load("res://universe/universe_map.png")
	create_map()
	player = Player.instance()
	player.position.y = -400
	Globals.player = player
	Globals.asteroid_search = true # Player starts out in empty space
	add_child(player)
	add_child(GameScreenUI.instance())

	determine_gravity_source()
	#Testing
#	player.position = Globals.active_asteroid.position
#	player.position.y += 600

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
			if colorInfo.r == 0 and colorInfo.g == 0 and colorInfo.b == 0 : #black - Small x2
				asteroid = LargeAsteroid.instance()
				asteroid.scale.x = 2
				asteroid.scale.y = 2
				asteroid.res_type = asteroid.SMALL_BAL
			if colorInfo.r == 1 and colorInfo.g == 0 and colorInfo.b == 0 : #red - Med - Copper
				asteroid = LargeAsteroid.instance()
				asteroid.scale.x = 3
				asteroid.scale.y = 3
				asteroid.res_type = asteroid.MED_COPPER
			if colorInfo.r == 0 and colorInfo.g == 1 and colorInfo.b == 0 : #green - Med x3
				asteroid = LargeAsteroid.instance()
				asteroid.scale.x = 3
				asteroid.scale.y = 3
				asteroid.res_type = asteroid.MED_BAL
			if colorInfo.r == 0 and colorInfo.g == 0 and colorInfo.b == 1 : #blue - large x4
				asteroid = LargeAsteroid.instance()
				asteroid.scale.x = 4
				asteroid.scale.y = 4
				asteroid.res_type = asteroid.LG_BAL
			if colorInfo.r == 1 and colorInfo.g == 0 and colorInfo.b == 1 : #purple - huge
				asteroid = LargeAsteroid.instance()
				asteroid.scale.x = 6
				asteroid.scale.y = 6
				asteroid.res_type = asteroid.LG_BAL
			if colorInfo.r == 0 and colorInfo.g == 1 and colorInfo.b == 1 : #Blue Green - Med - Iron
				asteroid = LargeAsteroid.instance()
				asteroid.scale.x = 3
				asteroid.scale.y = 3
				asteroid.res_type = asteroid.MED_IRON
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
