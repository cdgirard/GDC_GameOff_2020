extends Area2D

enum {ROCK_PILE, IRON_PILE, COPPER_PILE}

var in_pool = false
var exploding = false
var type = ROCK_PILE

var home_asteroid

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_type(t) :
	type = t
	if type == ROCK_PILE :
		$Sprite.set_modulate(Color("ffffff"))
	elif type == IRON_PILE :
		$Sprite.set_modulate(Color("00dbff"))
	elif type == COPPER_PILE :
		$Sprite.set_modulate(Color("9f5e09"))

func reset() :
	position = Vector2(0,0)
	in_pool = false
	exploding = false
	home_asteroid = null
	get_node("Sprite").visible = true
	get_node("CollisionShape2D").set_deferred("disabled", false) 
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if exploding and not get_node("Explosion").emitting :
		in_pool = true
		Globals.rubble_pool.append(self)
		home_asteroid.remove_rubble_pile(self)
	pass

func _on_RubblePile_area_entered(area):
	if area.name == "ResourceSensor" :
		if type == ROCK_PILE :
			Globals.update_gathered(6.5,0.5,0.5,0,0,0)
		elif type == IRON_PILE :
			Globals.update_gathered(0.5,6.5,0.5,0,0,0)
		elif type == COPPER_PILE :
			Globals.update_gathered(0.5,0.5,6.5,0,0,0)
		exploding = true
		get_node("Explosion").emitting = true
		get_node("Sprite").visible = false
		get_node("CollisionShape2D").set_deferred("disabled", true)
