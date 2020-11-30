extends RigidBody2D

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

#For Growing the Player over time
var small_img = load("res://player/images/Asteroids_32x32_001.png")
var med_img = load("res://player/images/Asteroids_64x64_001.png")
var large_img = load("res://player/images/Asteroids_128x128_001.png")
var huge_img = load("res://player/images/Asteroids_256x256_001.png")

var images = [small_img, small_img, med_img, large_img, huge_img]
var scale_size = [0.0, 300.0, 600.0, 1200.0, 2400.0]
var boundary_rad = [0.0, 15.0, 30.0, 60.0, 120.0]
var scale_base = [Vector2(0.0,0.0),Vector2(1.0,1.0), Vector2(1.0,1.0), Vector2(1.0,1.0), Vector2(1.0,1.0)]

#For testing growth code
#var size_timer = 0.1

func _input(event):
	if Input.is_action_pressed("ui_up") and not pressed and Globals.copper_portal:
		print("Up copper")
		get_node("CopperPortalEffect").play()
		var angle = (position - Globals.active_asteroid.position).normalized()
		self.apply_impulse(angle,angle*30*Globals.copper_composition)
		Globals.asteroid_search = true
		pressed = true
	elif Input.is_action_pressed("ui_up") and not pressed and Globals.iron_portal:
		print("Up iron")
		get_node("IronPortalEffect").play()
		var angle = (position - Globals.active_asteroid.position).normalized()
		self.apply_impulse(angle, angle*10*Globals.iron_composition)
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

#Keep growing to final max image then just keeps scaling that up.
func adjust_size() :
	var total_res = Globals.rock_gathered+Globals.iron_gathered+Globals.copper_gathered
	var index = 1
	while (scale_size[index] < total_res) and (index != (scale_size.size()-1)):
		index += 1
	
	var scaleAmt = 1+(total_res-scale_size[index-1])/(scale_size[index]-scale_size[index-1])
	scaleAmt = min(5,scaleAmt)

#We can't scale up the whole player object because we keep using bigger and 
#bigger images so each thing needs to scale differenly.
	get_node("CollisionShape2D/PlayerImg").texture = images[index]
	get_node("CollisionShape2D").shape.radius = scaleAmt*boundary_rad[index]
	#Resizing Area2D collision shape breaks it if we don't defer.
	get_node("PortalSensor/CollisionShape2D").get_shape().set_deferred("radius", scaleAmt*boundary_rad[index])
	get_node("CollisionShape2D/PlayerImg").scale = scaleAmt*scale_base[index]
	
	var next_zoom = Vector2(max(1,scaleAmt*index*0.5),max(1,scaleAmt*index*0.5))
	next_zoom.x = min(4,next_zoom.x)
	next_zoom.y = min(4,next_zoom.y)
	var tmp_zoom = get_node("Camera2D").zoom.linear_interpolate(next_zoom,0.005)
	get_node("Camera2D").zoom = tmp_zoom
	#print(index," ",scaleAmt)

	
		
func background_music():
	if Globals.asteroid_search and not $FlyThroughSpace.playing :
		$FlyThroughSpace.play(7)
	if $FlyThroughSpace.playing :
		
		if not Globals.asteroid_search :
			$FlyThroughSpace.playing = false
		else :
			var dist = position.distance_to(Globals.active_asteroid.position)
			if dist < 2000 :
				var volume = (1 - dist / 2000)*25 + 10
				$FlyThroughSpace.volume_db = -volume
			else :
				$FlyThroughSpace.volume_db = -10
	
func _process(delta):
# Was for testing growth code.
#	size_timer -= delta
#	if size_timer <= 0 :
#		Globals.update_gathered(10,10,10)
#		size_timer = 1

	background_music()
	if sound_effects :
		play_sound()
	#if not get_node
	var pos_change = (prev_position - position)
	dist_moved = pos_change.length()
	
	adjust_size()

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
		var vel_change = 160.0 / get_node("CollisionShape2D/PlayerImg").texture.get_width()
		#print("Vel: ",vel_change)
		if Globals.asteroid_direction == 1 :
			angular_velocity = -vel_change
		elif Globals.asteroid_direction == -1 :
			angular_velocity = vel_change
			
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
	if not Globals.starting : # Wait for start sequence to finish before starting to move
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
	Globals.update_gathered(1,1,1)
	sound_effects = true
	Globals.asteroid_search = false
	# Temp code for comsuming resources
	
	
func _on_Player_body_exited(body):
	sound_effects = false
	if dist_moved > 0.4 :
		if (sound_effect_mode == 2) or (sound_effect_mode == 0) :
			sound_effect_mode += 1


func _on_PortalSensor_area_entered(area):
	if area.get_parent().name == "CopperPortal" :
		Globals.copper_portal = true
	if area.get_parent().name == "IronPortal" :
		Globals.iron_portal = true
	pass # Replace with function body.


func _on_PortalSensor_area_exited(area):
	if area.get_parent().name == "CopperPortal":
		Globals.copper_portal = false
	if area.get_parent().name == "IronPortal" :
		Globals.iron_portal = false
	pass # Replace with function body.
