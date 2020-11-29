extends Node

var starting = false

var active_asteroid
var asteroid_motion = false
var asteroid_direction = 0
var asteroid_search = false

var rock_gathered = 0
var iron_gathered = 0
var copper_gathered = 0

var rock_composition = 0
var iron_composition = 0
var copper_composition = 0

var copper_portal = false
var iron_portal = false

var contact_rock = false
var contact_iron_ore = false
var contact_copper_ore = false

var enemy_pool = []

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	update_gathered(0,0,0)
	print("Here")
	pass # Replace with function body.

func get_enemy_from_pool() :
	if enemy_pool.size() > 0 :
		var pool_enemy = enemy_pool[0]
		pool_enemy.reset()
		enemy_pool.remove(0)
		return pool_enemy

func update_gathered(rock,iron,copper) :
	rock_gathered += rock
	rock_gathered = max(0,rock_gathered)
	iron_gathered += iron
	iron_gathered = max(0,iron_gathered)
	copper_gathered += copper
	copper_gathered = max(0,copper_gathered)
	var total = rock_gathered + iron_gathered + copper_gathered
	if total == 0 :
		rock_composition = 0
		iron_composition = 0
		copper_composition = 0
	else :
		#4 on each side
		rock_composition = min(100, compute_composition(rock_gathered,total))
		iron_composition = min(100, compute_composition(iron_gathered,total))
		copper_composition = min(100,compute_composition(copper_gathered,total))

#We could eventually make the gold, gems, etc the multiplier here.
func compute_composition(value,total) :
	return (4 + (value*92 / total))*1.5
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
