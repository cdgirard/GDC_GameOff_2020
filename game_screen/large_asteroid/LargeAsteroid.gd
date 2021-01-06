extends StaticBody2D

enum { NONE, ROCK, IRON, COPPER, GEM, GOLD, ALNICO }
enum {SMALL_BAL, SMALL_IRON, SMALL_COPPER, MED_BAL, MED_IRON, MED_COPPER, LG_BAL, LG_IRON, LG_COPPER}

onready var Rock = preload("res://game_screen/rock/Rock.tscn")
onready var IronOre = preload("res://game_screen/iron_ore/IronOre.tscn")
onready var CopperOre = preload("res://game_screen/copper_ore/CopperOre.tscn")
onready var BlueGems = preload("res://game_screen/blue_gems/BlueGems.tscn")
onready var AlNicoAlloy = preload("res://game_screen/alnico_alloy/AlNicoAlloy.tscn")
onready var Gold = preload("res://game_screen/gold/Gold.tscn")
onready var Portal = preload("res://game_screen/portal/Portal.tscn")
onready var SmallEnemyRock = preload("res://game_screen/small_enemy_rock/SmallEnemyRock.tscn")
# Declare member variables here. Examples:
var bal_res_small = [GOLD, ROCK, GEM, IRON, ALNICO, COPPER, NONE, ROCK, NONE, IRON, NONE, COPPER, NONE, ROCK, NONE, IRON, NONE ]
var iron_res_small = [NONE, IRON, NONE, IRON, NONE, COPPER, NONE, ROCK, NONE, IRON, NONE, IRON, NONE, ROCK, NONE, IRON, NONE ]
var copper_res_small = [NONE, COPPER, NONE, IRON, NONE, COPPER, NONE, ROCK, NONE, IRON, NONE, COPPER, NONE, ROCK, NONE, COPPER, NONE ]
var bal_res_med = [ROCK, ROCK, NONE, IRON, NONE, COPPER, IRON, ROCK, NONE, IRON, NONE, COPPER, NONE, ROCK, COPPER, IRON, NONE ]
var iron_res_med = [IRON, ROCK, NONE, IRON, NONE, COPPER, IRON, ROCK, NONE, IRON, NONE, COPPER, NONE, ROCK, IRON, IRON, NONE ]
var copper_res_med = [COPPER, ROCK, NONE, IRON, NONE, COPPER, COPPER, ROCK, NONE, IRON, NONE, COPPER, NONE, ROCK, COPPER, IRON, NONE ]
var bal_res_lg = [IRON, ROCK, COPPER, IRON, ROCK, COPPER, IRON, ROCK, COPPER, IRON, ROCK, COPPER, IRON, ROCK, COPPER, IRON, ROCK ]
var iron_res_lg = [IRON, ROCK, IRON, IRON, ROCK, COPPER, IRON, ROCK, IRON, IRON, ROCK, COPPER, IRON, ROCK, IRON, IRON, ROCK ]
var copper_res_lg = [COPPER, ROCK, COPPER, IRON, ROCK, COPPER, COPPER, ROCK, COPPER, IRON, ROCK, COPPER, COPPER, ROCK, COPPER, IRON, ROCK ]

#This should be set when the asteroid is created
export var asteroid_radius = 800
var rotation_speed = 0.075
var my_scale = 1.25
var asteroid_rad

var enemies = {} #May use recycling pattern here, but store extras in Globals for all asteroids
var MAX_RUBBLE_PILES = 5.0
var rubble_piles = {}
var res_type = SMALL_BAL

# Called when the node enters the scene tree for the first time.
func _ready():
	attach_resources()
	attach_portals()
	$RollinMusic.volume_db = Globals.music_volume
	$RollinMusic.playing = false
	asteroid_rad = $Sprite.texture.get_size()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not Globals.display_thought : #Shut it all down while printing a message.
		spawn_enemies()
		#adjust_music()
		rotate_asteroid()

func get_position() :
	return self.position

func adjust_music() :
	if self == Globals.active_asteroid and Universe.player != null:
		var dist = global_position.distance_to(Universe.player.position)
		
		var max_dist = Universe.asteroid_scale*asteroid_radius*2 #Not sure if this needs more work
		if dist <= max_dist and not $RollinMusic.playing:
			$RollinMusic.playing = true
			$RollinMusic.volume_db = max(-80,Globals.music_volume-50)
		elif dist <= max_dist and $RollinMusic.playing :
			dist = max(dist,asteroid_radius)
			$RollinMusic.volume_db = max(-80,-50 * ((dist / max_dist) - 0.5) + Globals.music_volume)
	
	if self != Globals.active_asteroid and $RollinMusic.playing :
		$RollinMusic.playing = false

func rotate_asteroid() :
	Globals.asteroid_direction = 0
	if Input.is_action_pressed("ui_right"):
		rotation_degrees += rotation_speed
		Globals.asteroid_motion = true
		Globals.asteroid_direction = 1
	elif Input.is_action_pressed("ui_left"):
		rotation_degrees -= rotation_speed
		Globals.asteroid_motion = true
		Globals.asteroid_direction = -1
func map_type():
	match res_type :
		SMALL_BAL: 
			return bal_res_small
		SMALL_IRON :
			return iron_res_small
		SMALL_COPPER :
			return copper_res_small
		MED_BAL :
			return bal_res_med
		MED_IRON :
			return iron_res_med
		MED_COPPER :
			return copper_res_med
		LG_BAL :
			return bal_res_lg
		LG_IRON :
			return iron_res_lg
		LG_COPPER :
			return copper_res_lg

func add_rubble_pile(rubble) :
	rubble.home_asteroid = self
	add_child(rubble)
	rubble_piles[rubble.name] = rubble

func remove_rubble_pile(rubble) :
	rubble_piles.erase(rubble.name)
	remove_child(rubble)
	rubble.name = "RubblePile"

func add_enemy(enemy) :
	enemy.home_asteroid = self
	Universe.game_screen.add_child(enemy) #Can't attach to asteroid or messes up a lot of stuff.
	enemies[enemy.name] = enemy
	
func remove_enemy(enemy) :
	enemies.erase(enemy.name)
	Universe.game_screen.remove_child(enemy)
	enemy.name = "SmallEnemyRock"

func attach_resources() :
	var resources = map_type()
	var res_points = get_node("ResourcePoints")
	var count = 0
	for node in res_points.get_children() :
		var res_node = null
		match resources[count] :
			ROCK :
				res_node = Rock.instance()
			IRON :
				res_node = IronOre.instance()
			COPPER :
				res_node = CopperOre.instance()
			GEM :
				res_node = BlueGems.instance()
			GOLD :
				res_node = Gold.instance()
			ALNICO :
				res_node = AlNicoAlloy.instance()
		if res_node != null :
			#Camera Zoom Initial Size: 0.5
			#2nd Size: 0.6 
			#3rd Size: 1.2
			#4th Size: 2
			#Final Size: 4
			
			#Asteroid Scale for Camera Zoom:
			#2 zoom: Scale 2
			#2.5+ zoom: Scale 2.5
			#1 zoom: Scale 1.25
			#Max camera zoom in: 0.5 at Scale 1.25
			
			#Initial Asteroid Size: 12
			#2nd size: 8
			#3rd size: 4
			#4th size: 2
			#final size: 1
			res_node.my_asteroid = self
			node.scale = Vector2(1.25,1.25) # This needs to stay the initial base scale
			res_node.scale.x = Universe.asteroid_scale/ 12
			res_node.scale.y = Universe.asteroid_scale / 12
			node.add_child(res_node)
			
		count += 1

# I wonder if there is a way to make a generic portal that gets set to a type.
func attach_portals() :
	var portal_points = get_node("PortalPoints")
	for node in portal_points.get_children() :
		var port_node = Portal.instance()
		port_node.my_asteroid = self
		if node.name == "PortalPoint2":
			port_node.type = port_node.COPPER_PORTAL
		else:
			port_node.type = port_node.IRON_PORTAL
		port_node.scale.x *= 1 / scale.x
		port_node.scale.y *= 1 / scale.y
		port_node.get_node("Animation").playing = true
		node.add_child(port_node)

#We need to set the mass of the enemy based on its size.
func spawn_enemies() :
	#Player is too large for small enemy to hurt it now.
	if Universe.player != null and Universe.player.scale_size[3] < Globals.get_total_resources() :
		return
	var asteroid = Globals.active_asteroid
	if asteroid == self and not Globals.asteroid_search and len(enemies) < 1:
		var enemy = Globals.get_enemy_from_pool()
		if enemy == null :
			enemy = SmallEnemyRock.instance()
		#Set type here
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var enemy_type = rng.randf_range(0.0,3.0)
		print(enemy_type)
		if enemy_type < 1.0 :
			enemy.set_type(enemy.ROCK_ENEMY)
		elif enemy_type >= 1.0 and enemy_type < 2.0 :
			enemy.set_type(enemy.IRON_ENEMY)
		elif enemy_type > 2.0 :
			enemy.set_type(enemy.COPPER_ENEMY)
		enemy.get_node("AnimatedSprite").playing = true
		enemy.position = global_position
		var vec_dir = global_position - Universe.player.global_position
		var loc_pos_vec = vec_dir.normalized()
#		var x_loc = Globals.rng.randf_range(-1.0,1.0)
#		var y_loc = Globals.rng.randf_range(-1.0,1.0)
#		if abs(x_loc) < 0.1 and abs(y_loc) < 0.1 :
#			x_loc = 0.5
#			y_loc = 0.5
#		var loc_pos_vec = Vector2(x_loc, y_loc).normalized()
		
		enemy.position.y += loc_pos_vec.y*asteroid_radius*my_scale*1.4
		enemy.position.x += loc_pos_vec.x*asteroid_radius*my_scale*1.4
		enemy.attack_range = enemy.BASE_ATTACK_RANGE * my_scale
		enemy.in_pool = false
		#print(position, " ",enemy.position)
		add_enemy(enemy)

#Compute the angle in degrees to rotate an object by so it points in the
#direction of the normal for the collisiton polygon line segment at that
#point.  Assumes the collision polygon points are in a counter clockwise
#order.  Uses the relative position to the asteroid, not global position.
func compute_deg2collision_body(pos) :
	var col_points = $CollisionPolygon2D.polygon
	var min_dist = -1
	var min_index = -1
	for index in range(len(col_points)) :
		var point = col_points[index]
		var loc_dist = abs(pos.distance_to(point))
		if min_dist == -1 :
			min_dist = loc_dist
			min_index = index
		elif min_dist > loc_dist :
			min_dist = loc_dist
			min_index = index
	var other_index = (min_index + 1) % len(col_points)
	var other_dist = abs(pos.distance_to(col_points[other_index]))
	var tmp_index = (min_index - 1)
	var tmp_dist = abs(pos.distance_to(col_points[tmp_index]))
	if tmp_dist < other_dist :
		other_dist = tmp_dist
		other_index = tmp_index
	var unit_vec = null
	if min_index == len(col_points) - 1  and other_index == 0:
		min_index = -1
	if other_index == len(col_points) - 1 and min_index == 0:
		other_index = -1
	if min_index < other_index :
		unit_vec = (col_points[min_index] - col_points[other_index]).normalized()
	else :
		unit_vec = (col_points[other_index] - col_points[min_index]).normalized()
	var unit_angle = unit_vec.angle()
	return rad2deg(unit_angle)

