extends StaticBody2D

onready var BlueGems = preload("res://blue_gems/BlueGems.tscn")
onready var CopperPortal = preload("res://copper_portal/CopperPortal.tscn")
onready var SmallEnemyRock = preload("res://small_enemy_rock/SmallEnemyRock.tscn")
# Declare member variables here. Examples:

export var asteroid_radius = 800

var enemies = [] #May use recycling pattern here, but store extras in Globals for all asteroids

# Called when the node enters the scene tree for the first time.
func _ready():
	attach_resources()
	attach_portals()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	spawn_enemies()
	
	var count = 0
	while count < enemies.size() :
		if enemies[count].in_pool :
			enemies.remove(count)
		else :
			count += 1
			
	
	Globals.asteroid_direction = 0
	if Input.is_action_pressed("ui_right"):
		rotation_degrees += .5
		Globals.asteroid_motion = true
		Globals.asteroid_direction = 1
	elif Input.is_action_pressed("ui_left"):
		rotation_degrees -= .5
		Globals.asteroid_motion = true
		Globals.asteroid_direction = -1

func attach_resources() :
	var res_points = get_node("ResourcePoints")
	for node in res_points.get_children() :
		var res_node = BlueGems.instance()
		res_node.scale.x = 1 / scale.x
		res_node.scale.y = 1 / scale.y
		node.add_child(res_node)

func attach_portals() :
	var portal_points = get_node("PortalPoints")
	for node in portal_points.get_children() :
		var port_node = CopperPortal.instance()
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
		enemy.position.y += 900
		enemy.position.x += 200
		enemy.in_pool = false
		enemy.home_asteroid = self
		#print(position, " ",enemy.position)
		get_parent().add_child(enemy) #Can't attach to asteroid or messes up a lot of stuff.
		enemies.append(enemy)
		
		
	
