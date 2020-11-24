extends RigidBody2D


#Have this increase as the player gets bigger.
var MAX_ORBIT_GRAVITY = 250
var MAX_ATTACK_GRAVITY = 1000
#Have this increase as the player gets bigger
var MAX_GRAVITY_PULL = 700
var gravity = Vector2()
var exploding = false
var home_asteroid = null
var initial_boost = false
var attack_range = 400
var attacking = false
var in_pool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func reset() :
	position = Vector2(0,0)
	in_pool = false
	exploding = false
	attacking = false
	initial_boost = false
	home_asteroid = null
	get_node("AnimatedSprite").visible = true
	get_node("AnimatedSprite").playing = false
	get_node("CollisionShape2D").set_deferred("disabled", false)

func attack_player(delta) :
	var dist = position.distance_to(Globals.player.position)
	if dist < attack_range or attacking:
		attacking = true
		var angle = (position - Globals.player.position).normalized()
		var gravity_str = 1
		dist = max(Globals.player.gravity_radius,dist)
		gravity_str = Globals.player.gravity_radius/dist
		gravity_str = sqrt(gravity_str) #scale it up some.

		gravity.x = -angle.x * MAX_ATTACK_GRAVITY * delta * gravity_str
		gravity.y = -angle.y * MAX_ATTACK_GRAVITY * delta * gravity_str
	#print(gravity)
		#print("Attacking: ",position)
#print(velocity)
		self.linear_velocity *= 0.96 #Dampen the old velocity so we are more accurate
		self.linear_velocity += gravity
		return true
	else :
		return false

func orbit_asteroid(delta) :
	var angle = (position - home_asteroid.position).normalized()
	var dist = position.distance_to(home_asteroid.position)
	gravity.x = -angle.x * MAX_ORBIT_GRAVITY * delta
	gravity.y = -angle.y * MAX_ORBIT_GRAVITY * delta
	#print("Orbit: ",linear_velocity)
	#self.linear_velocity *= 0.99
	#print("Damp: ",linear_velocity)
	self.linear_velocity += gravity
	#print("Orbit: ",position)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(position)
	if exploding and not get_node("Explosion").emitting :
		in_pool = true
		Globals.enemy_pool.append(self)
		get_parent().remove_child(self)
	if not initial_boost :
		#Valid boost range: 500 to 800
		linear_velocity += Vector2(-500,0)
		initial_boost = true
	if Globals.player != null and not exploding:
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
	pass
		
func _on_SmallEnemyRock_body_entered(body):
	print(body.name)
	if not exploding:
		if body.name == "Player" :
			Globals.update_gathered(-40,0,0)
		exploding = true
		self.angular_velocity = 0
		self.linear_velocity.x = 0
		self.linear_velocity.y = 0
		get_node("Explosion").emitting = true
		get_node("AnimatedSprite").visible = false
		get_node("AnimatedSprite").playing = false
		get_node("CollisionShape2D").set_deferred("disabled", true)
	pass # Replace with function body.
