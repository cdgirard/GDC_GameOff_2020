extends Node

#Don't like: 7, 10
#Can't decide: 4, 5
#Like the look of 2, 3, 6 (next biggestimage), 8 (biggest image)
onready var LargeAsteroid = preload("res://game_screen/large_asteroid/LargeAsteroid4.tscn")
onready var AsteroidBelt = preload("res://game_screen/asteroid_belt/AsteroidBelt.tscn")
onready var Player = preload("res://game_screen/player/Player.tscn")
onready var SunAndPlanets = preload("res://game_screen/sun_and_planets/SunAndPlanets.tscn")

var MAX_DIST = 15000
var game_screen
var universeSprite = Sprite.new()
var asteroid_scale = 1.25
var asteroid_belts = []
var solar_system
var player

var update_asteroid_belt = false

# Called when the node enters the scene tree for the first time.
func init_universe(gs):
	game_screen = gs
	#universeSprite.texture = load("res://universe/universe_map.png")
	create_map()
	player = Player.instance()
	#player.position = Vector2(-8000,8000) #Testing postiion - near the sun
	var pos = asteroid_belts[2].asteroids["A"].global_position
	player.position = pos + Vector2(0,-4000)
	Globals.asteroid_search = true # Player starts out in empty space
	determine_gravity_source()

func update_asteroid_scale(value) :
	
	#asteroid_scale = min(2.5,max(1.25,value))
	asteroid_scale = min(4.0,max(1.25,value+0.75))

	for belt in asteroid_belts :
		belt.update_asteroid_scale()
		

#This should probably go in Universe
func create_new_asteroid():
	var asteroid = null
	asteroid = LargeAsteroid.instance()
	asteroid.scale = Vector2(asteroid_scale,asteroid_scale)
	#Randomly set the scale - Don't adjust default scale
	#asteroid.scale.x = 2
	#asteroid.scale.y = 2
	#Randomly set the type
	asteroid.res_type = asteroid.SMALL_BAL
	return asteroid

#The asteroids next to each other in the same belt are too far apart.
func create_map() :
	solar_system = SunAndPlanets.instance()
	game_screen.add_child(solar_system)
	
	var ast_path = AsteroidBelt.instance()
	ast_path.scale = Vector2(11.0,11.0)
	game_screen.add_child(ast_path)
	ast_path.shift(-0.025)
	ast_path.set_spacing(0.065)
	asteroid_belts.append(ast_path)
	
	ast_path = AsteroidBelt.instance()
	ast_path.apply_scale(Vector2(16.0,16.0))
	game_screen.add_child(ast_path)
	ast_path.shift(-0.015)
	ast_path.set_spacing(0.04)
	asteroid_belts.append(ast_path)
	
	ast_path = AsteroidBelt.instance()
	ast_path.scale = Vector2(21.0,21.0)
	game_screen.add_child(ast_path)
	ast_path.set_spacing(0.03)
	asteroid_belts.append(ast_path)

#Udpated to use the new belt system
#How should we handle both asteroid and planets
func determine_gravity_source() :
	var min_dist = -1
	for belt in asteroid_belts :
		for slot in belt.asteroids :
			var pos = belt.asteroids[slot].global_position
			var dist = (pos - player.position).length()
			if min_dist == -1 :
				min_dist = dist
				Globals.active_asteroid = belt.asteroids[slot]
				Globals.active_planet = null
			elif min_dist > dist :
				min_dist = dist
				Globals.active_asteroid = belt.asteroids[slot]
				Globals.active_planet = null
	if Globals.planet_search : 
		for planet in solar_system.planets :
			var dist = (planet.global_position - player.position).length()
			#print("D: ",dist," MD: ",min_dist)
			if min_dist == -1 :
				min_dist = dist
				Globals.active_planet = planet
				Globals.active_asteroid = null
			elif min_dist > dist :
				min_dist = dist
				Globals.active_planet = planet
				Globals.active_asteroid = null

#This is used by the portals to determine the distance and direction
#of the asteroid that would be the best shot to reach.
func determine_gravity_source_in_dir(obj_pos, dir_to_look) :
	var target_data = [-1, -1, null]
	for belt in asteroid_belts :
		for slot in belt.asteroids :
			var pos = belt.asteroids[slot].global_position
			var ast_dir = (pos - obj_pos).normalized()
			var dist = pos.distance_to(obj_pos)
			var dir_diff = dir_to_look.distance_to(ast_dir)
			#print("Pos: ",pos," dist: ",dist, " dir_diff: ",dir_diff)
			if belt.asteroids[slot] != Globals.active_asteroid : #Make sure not the active asteroid
				if target_data[0] == -1:
					if dist < MAX_DIST :
						target_data[0] = dist
						target_data[1] = dir_diff
						target_data[2] = belt.asteroids[slot]
				elif target_data[1] > dir_diff and target_data[0] > dist: #In a better direction and closer
					target_data[0] = dist
					target_data[1] = dir_diff
					target_data[2] = belt.asteroids[slot]
				elif target_data[1] > dir_diff or target_data[0] > dist : #one of the two are better
					#print("Option - Dist: ",dist," Dir_Diff: ",dir_diff)
					var score_new = dir_diff + dist/MAX_DIST
					var score_old = target_data[1] + target_data[0]/MAX_DIST 
					if  score_new < score_old : # If combined less than one overall better  
						target_data[0] = dist
						target_data[1] = dir_diff
						target_data[2] = belt.asteroids[slot]
	if target_data[2] != null :
		return target_data[2]
	return null

#Causes the asteroid belts to update the location of the asteroids in the 
#belts, used when the player moves between asteroids.
func update_asteroid_belts() :
	for belt in asteroid_belts :
		belt.update_asteroids(player.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if update_asteroid_belt :
		update_asteroid_belt = false
		update_asteroid_belts()

#	pass
