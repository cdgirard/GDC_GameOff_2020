extends RigidBody2D

enum SIZE {small, medium, large}

# Declare member variables here. Examples:
var MAX_GRAVITY = 100
var MAX_GRAVITY_PULL = 6000
var velocity = Vector2()
var gravity = Vector2()
export var speed = 100
export var gravity_radius = 200
var prev_position
var roll_mode = false
var roll_timer = 0
var sound_effect_mode = 0
var sound_effects = false
var dist_moved = 0
var pressed = false

func _input(event):
	if Input.is_action_pressed("ui_up") and not pressed and Globals.copper_portal:
		print("Up")
		var angle = (position - Globals.active_asteroid.position).normalized()
		self.apply_impulse(angle,angle*10*Globals.copper_composition)
		Globals.asteroid_search = true
		pressed = true
	if Input.is_action_just_released("ui_up") :
		pressed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector2(0,0)
	prev_position = position
	#print(velocity)
	pass
		
func _process(delta):
	if sound_effects :
		play_sound()
	#if not get_node
	var pos_change = (prev_position - position)
	dist_moved = pos_change.length()

	prev_position = position
	if dist_moved < 0.05 and not roll_mode:
		roll_timer = 2.0
		add_torque(200.0)
		roll_mode = true
		Globals.asteroid_motion = false
	elif dist_moved > 0.2 and roll_mode :
		print(dist_moved)
		roll_timer = 0
		roll_mode = false
		add_torque(-applied_torque)
	elif dist_moved > 0.1 and not roll_mode:
		if Globals.asteroid_direction == 1 :
			angular_velocity = -5
		elif Globals.asteroid_direction == -1 :
			angular_velocity = 5
			
	if dist_moved < 0.2:
		get_node("MoveOnAsteroidSoundV1").volume_db = -80
		get_node("MoveOnAsteroidSoundV3").volume_db = -80
	elif dist_moved < 0.4 :
		get_node("MoveOnAsteroidSoundV1").volume_db = -15
	else :
		get_node("MoveOnAsteroidSoundV1").volume_db = -15
		get_node("MoveOnAsteroidSoundV3").volume_db = -15
	
	if Globals.asteroid_motion :
		roll_mode = false
		roll_timer = 0
		add_torque(-applied_torque)

	if roll_timer > 0  :
		roll_timer -= delta
	elif roll_mode :
		add_torque(-applied_torque*2)
		roll_timer = 2.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var angle = (position - Globals.active_asteroid.position).normalized()
	var dist = position.distance_to(Globals.active_asteroid.position)
	var gravity_str = 1
	dist = max(Globals.active_asteroid.asteroid_radius,dist)
	if dist > MAX_GRAVITY_PULL :
		gravity_str = 0
	else :
		gravity_str = Globals.active_asteroid.asteroid_radius/dist
	
	#print(angle)
	gravity.x = -angle.x * MAX_GRAVITY * delta
	gravity.y = -angle.y * MAX_GRAVITY * delta
	#print(velocity)
	self.linear_velocity += gravity
	#velocity += gravity

func play_sound() :
	var playing = true
	if (not get_node("MoveOnAsteroidSoundV1").playing) and (not get_node("MoveOnAsteroidSoundV2").playing) and (not get_node("MoveOnAsteroidSoundV3").playing) :
		playing = false
	if (not playing) and (sound_effect_mode == 0):
		get_node("MoveOnAsteroidSoundV1").play()
		sound_effect_mode = 1
	elif (not playing) and (sound_effect_mode == 1):
		get_node("MoveOnAsteroidSoundV3").play()
		sound_effect_mode = 2
	elif (not playing) and (sound_effect_mode == 2) :
		get_node("MoveOnAsteroidSoundV2").play()
		sound_effect_mode = 3
	elif (not playing) and (sound_effect_mode == 3) :
		get_node("MoveOnAsteroidSoundV3").play()
		sound_effect_mode = 0

func _on_Player_body_entered(body):
	sound_effects = true
	Globals.asteroid_search = false
	


func _on_Player_body_exited(body):
	sound_effects = false
	if dist_moved > 0.4 :
		if (sound_effect_mode == 2) or (sound_effect_mode == 0) :
			sound_effect_mode += 1


func _on_PortalSensor_area_entered(area):
	Globals.copper_portal = true
	pass # Replace with function body.


func _on_PortalSensor_area_exited(area):
	Globals.copper_portal = false
	pass # Replace with function body.
