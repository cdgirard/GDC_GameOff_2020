extends StaticBody2D

enum { NONE, ROCK, IRON, COPPER, GEM, GOLD, ALNICO }
enum {SMALL_BAL, SMALL_IRON, SMALL_COPPER, MED_BAL, MED_IRON, MED_COPPER, LG_BAL, LG_IRON, LG_COPPER}

onready var BlueGems = preload("res://blue_gems/BlueGems.tscn")
onready var Rock = preload("res://rock/Rock.tscn")
onready var IronOre = preload("res://iron_ore/IronOre.tscn")
onready var CopperOre = preload("res://copper_ore/CopperOre.tscn")
onready var CopperPortal = preload("res://copper_portal/CopperPortal.tscn")
onready var IronPortal = preload("res://iron_portal/IronPortal.tscn")
onready var SmallEnemyRock = preload("res://small_enemy_rock/SmallEnemyRock.tscn")
# Declare member variables here. Examples:
var bal_res_small = [NONE, ROCK, NONE, IRON, NONE, COPPER, NONE, ROCK, NONE, IRON, NONE, COPPER, NONE, ROCK, NONE, IRON, NONE ]
var iron_res_small = [NONE, IRON, NONE, IRON, NONE, COPPER, NONE, ROCK, NONE, IRON, NONE, IRON, NONE, ROCK, NONE, IRON, NONE ]
var copper_res_small = [NONE, COPPER, NONE, IRON, NONE, COPPER, NONE, ROCK, NONE, IRON, NONE, COPPER, NONE, ROCK, NONE, COPPER, NONE ]
var bal_res_med = [ROCK, ROCK, NONE, IRON, NONE, COPPER, IRON, ROCK, NONE, IRON, NONE, COPPER, NONE, ROCK, COPPER, IRON, NONE ]
var iron_res_med = [IRON, ROCK, NONE, IRON, NONE, COPPER, IRON, ROCK, NONE, IRON, NONE, COPPER, NONE, ROCK, IRON, IRON, NONE ]
var copper_res_med = [COPPER, ROCK, NONE, IRON, NONE, COPPER, COPPER, ROCK, NONE, IRON, NONE, COPPER, NONE, ROCK, COPPER, IRON, NONE ]
var bal_res_lg = [IRON, ROCK, COPPER, IRON, ROCK, COPPER, IRON, ROCK, COPPER, IRON, ROCK, COPPER, IRON, ROCK, COPPER, IRON, ROCK ]
var iron_res_lg = [IRON, ROCK, IRON, IRON, ROCK, COPPER, IRON, ROCK, IRON, IRON, ROCK, COPPER, IRON, ROCK, IRON, IRON, ROCK ]
var copper_res_lg = [COPPER, ROCK, COPPER, IRON, ROCK, COPPER, COPPER, ROCK, COPPER, IRON, ROCK, COPPER, COPPER, ROCK, COPPER, IRON, ROCK ]

export var asteroid_radius = 800

var enemies = [] #May use recycling pattern here, but store extras in Globals for all asteroids
export var res_type = SMALL_BAL

# Called when the node enters the scene tree for the first time.
func _ready():
	attach_resources()
	attach_portals()
	$RollinMusic.playing = false
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	spawn_enemies()
	if self == Globals.active_asteroid and Globals.player != null:
		var dist = position.distance_to(Globals.player.position)
		var max_dist = scale.x * 800
		var asteroid_rad = scale.x * 400 # Does not help it is an oval
		if dist <= max_dist and not $RollinMusic.playing:
			$RollinMusic.playing = true
			$RollinMusic.volume_db = -50
		elif dist <= max_dist and $RollinMusic.playing :
			dist = max(dist,asteroid_rad)
			$RollinMusic.volume_db = -50 * ((dist / max_dist) - 0.5) - 15
	
	if self != Globals.active_asteroid and $RollinMusic.playing :
		$RollinMusic.playing = false
	
	var count = 0
	while count < enemies.size() :
		if enemies[count].in_pool :
			enemies.remove(count)
		else :
			count += 1
			
	
	Globals.asteroid_direction = 0
	var rotation_speed = 0.5/scale.x
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
				pass
			GOLD :
				pass
			ALNICO :
				pass
		if res_node != null :
			res_node.scale.x = scale.x / 4
			res_node.scale.y = scale.y / 4
			node.add_child(res_node)
		count += 1

func attach_portals() :
	var portal_points = get_node("PortalPoints")
	for node in portal_points.get_children() :
		var port_node = null
		if node.name == "PortalPoint2":
			port_node = CopperPortal.instance()
		else:
			port_node = IronPortal.instance()
		port_node.scale.x *= 1 / scale.x
		port_node.scale.y *= 1 / scale.y
		port_node.get_node("AnimatedSprite").playing = true
		node.add_child(port_node)

func spawn_enemies() :
	var asteroid = Globals.active_asteroid
	if asteroid == self and not Globals.asteroid_search and enemies.size() < 1:
		var enemy = Globals.get_enemy_from_pool()
		print("From Pool: ",enemy)
		if enemy == null :
			enemy = SmallEnemyRock.instance()
			print("New Enemy")
		enemy.get_node("AnimatedSprite").playing = true
		enemy.position = self.position
		enemy.position.y += 450*scale.x
		enemy.position.x += 100*scale.x
		enemy.in_pool = false
		enemy.home_asteroid = self
		#print(position, " ",enemy.position)
		get_parent().add_child(enemy) #Can't attach to asteroid or messes up a lot of stuff.
		enemies.append(enemy)
		
		
	
