extends RigidBody2D

enum {ROCK_ENEMY, IRON_ENEMY, COPPER_ENEMY}

onready var RubblePile = preload("res://game_screen/rubble_pile/RubblePile.tscn")

#Have this increase as the player gets bigger.
var MAX_ORBIT_GRAVITY = 250
var MAX_ATTACK_GRAVITY = 1000
#Have this increase as the player gets bigger
var MAX_GRAVITY_PULL = 700
var gravity = Vector2()
var exploding = false
var home_asteroid = null
var initial_boost = false
var BASE_ATTACK_RANGE = 400
var attack_range = BASE_ATTACK_RANGE
var attacking = false
var in_pool = true
var type

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func reset() :
	position = Vector2(0,0)
	linear_velocity = Vector2(0,0)
	in_pool = false
	exploding = false
	attacking = false
	initial_boost = false
	home_asteroid = null
	get_node("AnimatedSprite").visible = true
	get_node("AnimatedSprite").playing = false
	get_node("CollisionShape2D").set_deferred("disabled", false) 

func attack_player(delta) :
	var player = Universe.player
	var dist = position.distance_to(player.position)
	if dist < attack_range or attacking:
		var diff_mult = 1
		if Globals.difficulty == 1 :
			diff_mult = 1.75
		elif Globals.difficulty == 4 :
			diff_mult = 0.9
		attacking = true
		var angle = (position - player.position).normalized()
		var gravity_str = 1.0
		dist = max(player.gravity_radius,dist)
		gravity_str = player.gravity_radius/dist
		gravity_str = sqrt(gravity_str) #scale it up some.

		gravity.x = -angle.x * MAX_ATTACK_GRAVITY * delta * gravity_str * diff_mult
		gravity.y = -angle.y * MAX_ATTACK_GRAVITY * delta * gravity_str * diff_mult

		#Dampen the old velocity so we are more accurate
		#Tring to dial in these numbers still.
		if Globals.difficulty == 1 :  #Nightmare
			self.linear_velocity *= 0.91 
		elif Globals.difficulty == 4 : #Easy Mode
			self.linear_velocity *= 0.97
		else :
			self.linear_velocity *= 0.96
		self.linear_velocity += gravity
		return true
	else :
		return false

func orbit_asteroid(delta) :
	var angle = (position - home_asteroid.global_position).normalized()
	gravity.x = -angle.x * MAX_ORBIT_GRAVITY * delta
	gravity.y = -angle.y * MAX_ORBIT_GRAVITY * delta
	self.linear_velocity += gravity

func set_type(t) :
	type = t
	if type == ROCK_ENEMY :
		$AnimatedSprite.set_modulate(Color("ffffff"))
	elif type == IRON_ENEMY :
		$AnimatedSprite.set_modulate(Color("00dbff"))
	elif type == COPPER_ENEMY :
		$AnimatedSprite.set_modulate(Color("9f5e09"))
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(position)
	if exploding and not get_node("Explosion").emitting :
		in_pool = true
		Globals.enemy_pool.append(self)
		home_asteroid.remove_enemy(self)
	elif Globals.asteroid_search :
		in_pool = true
		Globals.enemy_pool.append(self)
		home_asteroid.remove_enemy(self)

	if Universe.player != null and not exploding:
		if not attack_player(delta) and home_asteroid != null:
			orbit_asteroid(delta)
	elif exploding :
		self.linear_velocity.x = 0
		self.linear_velocity.y = 0
		self.angular_velocity = 0
	#print("Post: ",position)
	pass

func _physics_process(delta):
	#If we do the linear_velocity updates here I think the dampen effect takes over even more.
	if not initial_boost :
		#Valid boost range: 500 to 800
		var unit_vec = (global_position - home_asteroid.global_position).normalized()
		
		var unit_vec2 = null
		if Globals.rng.randf_range(0.0,1.0) > 0.5 :
			unit_vec2 = unit_vec.rotated(deg2rad(90))
		else :
			unit_vec2 = unit_vec.rotated(deg2rad(-90))
		var impulse_str = 450*home_asteroid.my_scale
		var impulse_vec = unit_vec2 * Vector2(impulse_str,impulse_str)
		#Looks like the impulse direction needs to be a unit vector
		#apply_impulse(Vector2.ONE.normalized(),impulse_vec)
		#Also, apply_impulse seems to break when we use a recycled object.
		linear_velocity = impulse_vec
		initial_boost = true

func _on_SmallEnemyRock_body_entered(body):
	if not exploding:
		if body.name == "Player" :
			#Check type - do damage based on type.
			if type == ROCK_ENEMY :
				Globals.update_gathered(-15,0,0,0,0,0)
			elif type == IRON_ENEMY :
				Globals.update_gathered(-5,-10,0,0,0,0)
			elif type == COPPER_ENEMY :
				Globals.update_gathered(-5,0,-10,0,0,0)
			if not Globals.first_attacked :
				Globals.first_attacked = true
				Globals.activate_display_thought(Globals.first_attacked_text)
		elif body.name == Globals.active_asteroid.name :
			var chance = Globals.rng.randf_range(0.0,home_asteroid.MAX_RUBBLE_PILES)
			if chance > len(home_asteroid.rubble_piles) :
				var rubble_pile = Globals.get_rubble_from_pool()
				if rubble_pile == null :
					rubble_pile = RubblePile.instance()
				if type == ROCK_ENEMY :
					rubble_pile.set_type(rubble_pile.ROCK_PILE)
				elif type == IRON_ENEMY :
					rubble_pile.set_type(rubble_pile.IRON_PILE)
				elif type == COPPER_ENEMY :
					rubble_pile.set_type(rubble_pile.COPPER_PILE)
				home_asteroid.add_rubble_pile(rubble_pile) #Not sure what to do if one chases the player to another asteroid
				#home_asteroid.rubble_piles.append(rubble_pile) 
				#Version 3 - Uses the collision polygon itself to determine rotation - moderatly tested
				#This relies on the collision polygon points having been placed in counter-clockwise order.
				#It might make sense to make this its own function if we start using it to figure out
				#orientation of all resource points.
				rubble_pile.global_position = self.global_position
				rubble_pile.rotation_degrees = home_asteroid.compute_deg2collision_body(rubble_pile.position)
				if not Globals.first_rubble :
					Globals.first_rubble = true
					Globals.activate_display_thought(Globals.first_rubble_text)
		exploding = true
		self.angular_velocity = 0
		self.linear_velocity.x = 0
		self.linear_velocity.y = 0
		get_node("Explosion").emitting = true
		get_node("AnimatedSprite").visible = false
		get_node("AnimatedSprite").playing = false
		get_node("CollisionShape2D").set_deferred("disabled", true)

	pass # Replace with function body.

var local_collision_pos
func _integrate_forces( state ):
	if(state.get_contact_count() >= 1):  #this check is needed or it will throw errors
		
		local_collision_pos = state.get_contact_collider_position(0)
		#print("Collided: ",local_collision_pos)
