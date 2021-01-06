extends RigidBody2D

# Declare member variables here. Examples:
var SPACE_GRAVITY = 100
var ASTEROID_GRAVITY = 200
var MAX_GRAVITY_PULL = 6000

var velocity = Vector2()
var gravity = Vector2()
export var speed = 150
export var gravity_radius = 200
var prev_position
var roll_mode = false
var roll_timer = 0
var roll_radius = 15

var sound_effect_mode = 0
var sound_effects = false
var dist_moved = 0
var pressed = false
var in_orbit = false
var mouse_click = Vector2()
var click_held = false
var spending_rate = 0.01
var has_resources = false

var flight_timer = 0 #Used to disable gravity during initial flight

#Used to ensure we don't disable active asteroid search right
#after portal launch
var portal_timer = 0

var prev_asteroid_position = null
var prev_ast_pos_change = Vector2(0,0)

#For Growing the Player over time
var small_img = load("res://game_screen/player/assets/Asteroids_32x32_001.png")
var med_img = load("res://game_screen/player/assets/Asteroids_64x64_001.png")
var large_img = load("res://game_screen/player/assets/Asteroids_128x128_001.png")
var huge_img = load("res://game_screen/player/assets/Asteroids_256x256_001.png")

var images = [small_img, small_img, med_img, large_img, huge_img]
var scale_size = [0.0, 300.0, 600.0, 1200.0, 2400.0]
var boundary_rad = [0.0, 15.0, 30.0, 60.0, 120.0]
var scale_base = [Vector2(0.0,0.0),Vector2(0.5,0.5), Vector2(0.5,0.5), Vector2(0.5,0.5), Vector2(0.5,0.5)]

var asteroid_radius = 1400   # How do we get this value from LargeAsteroid itself?

#For testing growth code
#var size_timer = 30

#Maybe after we fire off there is a ghost hit that disables asteroid search.
#Maybe a 0.075 timer before it can be re-enabled - gives us about 5 time slices.
func _input(event):
	#Bigger Portals Will Need a Bigger Boost Due to mass
	if Input.is_action_pressed("ui_up") and not pressed and Globals.copper_portal:
		pressed = true
		portal_timer = 0.075
		#print("Up copper: ", Globals.get_total_resources())
		get_node("CopperPortalEffect").play()
		var angle = (position - Globals.active_asteroid.global_position).normalized()
		var copper_boost = Globals.get_copper_boost()*Globals.portal_duration
		#print(copper_boost)
		if Globals.get_total_resources() < Globals.MOON_SIZE :
			self.apply_impulse(angle,angle*30*mass*copper_boost)
		else :
			self.apply_impulse(angle,angle*150*mass*copper_boost) #With multipliers working don't think need this now
			Globals.planet_search = true
		Globals.asteroid_search = true
		flight_timer = 2
		prev_asteroid_position = null
	elif Input.is_action_pressed("ui_up") and not pressed and Globals.iron_portal:
		portal_timer = 0.075
		#print("Up iron: ",Globals.get_total_resources())
		get_node("IronPortalEffect").play()
		var angle = (position - Globals.active_asteroid.global_position).normalized()
		var iron_boost = Globals.get_iron_boost()*Globals.portal_duration
		#print(iron_boost)
		if Globals.get_total_resources() < Globals.MOON_SIZE :
			self.apply_impulse(angle, angle*30*mass*iron_boost)
		else :
			self.apply_impulse(angle, angle*150*mass*iron_boost)
			Globals.planet_search = true
		Globals.asteroid_search = true
		flight_timer = 2
		prev_asteroid_position = null
		pressed = true
	if Input.is_action_just_released("ui_up"):
		pressed = false
	
	#toggles if mouse button held
	if event.is_action_pressed("click"):
		click_held = true
	if event.is_action_released("click"):
		click_held = false
		get_node("Particles2D").emitting = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Camera2D.current = true
	Globals.active_camera = $Camera2D
	velocity = Vector2(0,0)
	prev_position = position
	$MoveOnAsteroidSoundV1.volume_db = Globals.fx_volume
	$MoveOnAsteroidSoundV2.volume_db = Globals.fx_volume
	$MoveOnAsteroidSoundV3.volume_db = Globals.fx_volume
	$CopperPortalEffect.volume_db = Globals.fx_volume
	$IronPortalEffect.volume_db = Globals.fx_volume
	if Globals.music_volume > -80 :
		$FlyThroughSpace.volume_db = Globals.music_volume + 10
	else :
		$FlyThroughSpace.volume_db = -80
	#set particles to no longer emit
	get_node("Particles2D").emitting = false
	pass
	
#Keep growing to final max image then just keeps scaling that up.
func adjust_size() :
	var total_res = Globals.rock_gathered+Globals.iron_gathered+Globals.copper_gathered
	var index = 1
	while (scale_size[index] < total_res) and (index != (scale_size.size()-1)):
		index += 1
	


	var scaleAmt = 1+(total_res-scale_size[index-1])/(scale_size[index]-scale_size[index-1])
	scaleAmt = min(5,scaleAmt)
	#For the asteroid sizes when the player launches I don't think we can
	# resize existing asteroids easily, but I am wondering if we can destroy
	# and recreate the asteroids or don't start with as many per belt and so
	# all new ones get scaled up.  If I can't resize an asteroid, then will
	#want to go at it the other way.  Test by resizing the asteroid the player
	#is on as the player grows and see how that goes.
	#ScaleAmt at size 0: 1  (index = 1)  Camera: 0.5
	#ScaleAmt at size 0.99: 1.99
	#ScaleAmt at size 1: 1.01 (index = 2) Camera: 0.6
	#ScaleAmt at size 1.99: 1.99
	#ScaleAmt at size 2: 1.01 (index = 3) Camera: 1.2
	#ScaleAmt at size 2.99: 1.99
	#ScaleAmt at size 3: 1.01 (index = 4) Camera: 2
	#ScaleAmt at size 3.99: 1.99  
	#ScaleAmt at size 4: 2 (index does not increase past 4) Camera: 3
	#ScaleAmt at Final: 5 (index = 4) Camera: 4
			#Camera Zoom Initial Size: 0.5
			#2nd Size: 0.6 
			#3rd Size: 1.2
			#4th Size: 2
			#Final Size: 4
			

	
			
			#Initial Asteroid Size: 12
			#2nd size: 8
			#3rd size: 4
			#4th size: 2
			#final size: 1


#We can't scale up the whole player object because we keep using bigger and 
#bigger images so each thing needs to scale differenly.
	get_node("CollisionShape2D/PlayerImg").texture = images[index]
	roll_radius = scaleAmt*boundary_rad[index]*scale_base[index].x
	get_node("CollisionShape2D").shape.radius = roll_radius
	#Resizing Area2D collision shape breaks it if we don't defer.
	get_node("PortalSensor/CollisionShape2D").get_shape().set_deferred("radius", roll_radius)
	get_node("ResourceSensor/CollisionShape2D").get_shape().set_deferred("radius", roll_radius)
	get_node("PlanetSensor/CollisionShape2D").get_shape().set_deferred("radius", roll_radius)
	get_node("CollisionShape2D/PlayerImg").scale = scaleAmt*scale_base[index]
	var part_zoom = scaleAmt + index - 1
	$Particles2D.scale = Vector2(part_zoom, part_zoom)
	
	var zoom_scale = (scaleAmt + index - 1)*0.4
	var next_zoom = Vector2(max(0.65,zoom_scale),max(0.65,zoom_scale))
	var ast_zoom = Vector2(max(0.5,zoom_scale),max(0.5,zoom_scale))
	if Globals.asteroid_search :
		next_zoom = Vector2(min(4,next_zoom.x*2),min(4,next_zoom.y*2))
	#ScaleAmt at size 0: 1  (index = 1)  Camera: 0.5 (Actual: 0.5) .4
	#ScaleAmt at size 0.99: 1.99                     (Actual: 1.0) .8
	#ScaleAmt at size 1: 1.01 (index = 2) Camera: 0.6 (Actual: 1.0) .8
	#ScaleAmt at size 1.99: 1.99                     (Actual: 1.5)  1.2
	#ScaleAmt at size 2: 1.01 (index = 3) Camera: 1.2  (Actual: 1.5)  1.2
	#ScaleAmt at size 2.99: 1.99                       (Actual: 2.0) 1.6
	#ScaleAmt at size 3: 1.01 (index = 4) Camera: 2  (Actual: 2.0) 1.6
	#ScaleAmt at size 3.99: 1.99                     (Actual: 2.5)  2
	#ScaleAmt at size 4: 2 (index does not increase past 4) Camera: 3 (Actual: 2.5) 2
	#ScaleAmt at Final: 5 (index = 4) Camera: 4                       (Actual: 4) 3.2
	next_zoom.x = min(4,next_zoom.x)
	next_zoom.y = min(4,next_zoom.y)
	var cam_zoom = get_node("Camera2D").zoom.linear_interpolate(next_zoom,0.005)
	get_node("Camera2D").zoom = cam_zoom
	
			#Asteroid Scale for Camera Zoom:
			#2 zoom: Scale 2
			#2.5+ zoom: Scale 2.5
			#1 zoom: Scale 1.25
			#Max camera zoom in: 0.5 at Scale 1.25
	Universe.update_asteroid_scale(ast_zoom.x) 
	#print("Scale: ",Universe.asteroid_scale," ",next_zoom.x)
	#print(index," ",scaleAmt)


func adjust_bgm_dynamic_layer01():
	if MusicPlayer.get_master_volume() == Globals.MIN_VOLUME:
		return
	if Globals.asteroid_search and not MusicPlayer.is_track_playing(0):
		MusicPlayer.track_play(MusicPlayer.bgm_dynamic_layer01, 0)
	if MusicPlayer.is_track_playing(0):
		var dist = 0
		var max_dist = asteroid_radius*1.6
		if Globals.active_asteroid != null :
			dist = position.distance_to(Globals.active_asteroid.global_position)
		elif Globals.active_planet != null :
			dist = position.distance_to(Globals.active_planet.global_position)
		if Globals.music_volume > -80 :
			if dist <= max_dist:
				var volume = max(-80, -70 * (1 - (dist / max_dist)) -6)
				MusicPlayer.track[0].volume_db = volume
			else :
				MusicPlayer.track[0].volume_db = -6
		else :
			MusicPlayer.track_stop(0)
	#print(MusicPlayer.track[0].volume_db)


func adjust_bgm_default() :
	if MusicPlayer.get_master_volume() == Globals.MIN_VOLUME:
		return
	if Globals.active_asteroid != null:
		var asteroid_position = Globals.active_asteroid.global_position
		var dist = global_position.distance_to(asteroid_position)
		var max_dist = asteroid_radius*2
		
		if dist <= max_dist and not MusicPlayer.is_track_playing(1):
			MusicPlayer.track_load(MusicPlayer.bgm_default, 1)
			MusicPlayer.track[1].play((MusicPlayer.track[0].get_playback_position()))
			MusicPlayer.track[1].volume_db = max(-80,MusicPlayer.get_master_volume()-50)
		elif dist <= max_dist and MusicPlayer.is_track_playing(1):
			dist = max(dist, asteroid_radius)
			MusicPlayer.track[1].volume_db = max(-80,-50 * ((dist / max_dist) - 0.5) -6)
		elif Globals.asteroid_search:
			MusicPlayer.track[1].volume_db = Globals.MIN_VOLUME
	else:
		MusicPlayer.track[1].volume_db = Globals.MIN_VOLUME
	#print(MusicPlayer.track[1].volume_db)


func _process(delta):
#	# Hold spacebar to fastforward (testing only)
	if Input.is_action_pressed("ui_select"):
		Engine.time_scale = lerp(Engine.time_scale, 6, 0.01)
	else:
		Engine.time_scale = lerp(Engine.time_scale, 1, 0.1)

	
# Was for testing growth code.
#	size_timer -= delta
#	if size_timer <= 0 :
#		Globals.update_gathered(10,10,10,0,0,0)
#		size_timer = 1.0
#		print(mass, " ",weight)
	
	adjust_bgm_dynamic_layer01()
	adjust_bgm_default()
	
	if sound_effects :
		play_sound()
	#if not get_node
	var pos_change = (prev_position - position)
	dist_moved = pos_change.length()
	
	adjust_size()
	

	#print(linear_velocity)
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
		var vel_change = 60.0 / roll_radius
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
	
	#check for resources
	if ((Globals.rock_gathered > 1) and (Globals.iron_gathered > 1) and (Globals.copper_gathered > 1)) :
		has_resources = true
	else :
		has_resources = false
	
	#grabs mouse position and display effect
	if click_held and has_resources:
		mouse_click = get_global_mouse_position()
		#get direction to mouse cursor, reverse it, then set the rotation of the particles
		get_node("Particles2D").rotation = position.angle_to_point(mouse_click) - rotation #- (PI/2)
		get_node("Particles2D").emitting = true
		#lose resources
		Globals.update_gathered((-1.0/60.0), (-1.0/60.0), (-1.0/60.0), 0, 0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if in_orbit :  #Do no more physics processing if in orbit
		return
	if Globals.copper_portal or Globals.iron_portal:
		Globals.portal_duration += delta / 3
		if Globals.portal_duration > 1:
			Globals.portal_duration = 1
	if portal_timer > 0 :
		portal_timer -= delta
	if flight_timer >= 0 :
		flight_timer -= delta
		return

	#So player keeps up with the asteroid
	if Globals.asteroid_search :
		prev_asteroid_position = null
	else :
		if prev_asteroid_position == null and Globals.active_asteroid != null :
			prev_asteroid_position = Globals.active_asteroid.global_position
		elif Globals.active_asteroid != null :
			#Remove Old Velocity
			var vel_force = -prev_ast_pos_change*10
			linear_velocity += vel_force
			#print("A: ",position)
			#Update Velocity Based on Recent Asteroid Movment
			var ast_pos_change = Globals.active_asteroid.global_position - prev_asteroid_position
			prev_ast_pos_change = ast_pos_change
			prev_asteroid_position = Globals.active_asteroid.global_position
			#Add New Velocity
			vel_force = ast_pos_change*10
			linear_velocity += vel_force
			#print("B: ",linear_velocity)

	var grav_pos = Vector2(0,0)
	var grav_rad = 0
	if Globals.active_planet == null :
		grav_pos = Globals.active_asteroid.global_position
		grav_rad = Globals.active_asteroid.asteroid_radius
	else :
		grav_pos = Globals.active_planet.global_position
		grav_rad = Globals.active_planet.planet_radius

	var angle = (position - grav_pos).normalized()
	var dist = position.distance_to(grav_pos)
	dist = max(grav_rad,dist)
	
	if Globals.asteroid_search :
		gravity.x = -angle.x * SPACE_GRAVITY * delta
		gravity.y = -angle.y * SPACE_GRAVITY * delta
	else :
		gravity.x = -angle.x * ASTEROID_GRAVITY * delta
		gravity.y = -angle.y * ASTEROID_GRAVITY * delta
	#print(velocity)
	self.linear_velocity += gravity
	#velocity += gravity
	
	#direct movement
	if click_held and has_resources:
		#linear_velocity = linear_velocity + (position.direction_to(mouse_click) * speed * delta) with gravity
		linear_velocity = position.direction_to(mouse_click) * speed #* delta
		#set particle gravity to gravity
		get_node("Particles2D").get_process_material().gravity.y = gravity.y
		get_node("Particles2D").get_process_material().gravity.x = gravity.x

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
	#Globals.update_gathered(10,10,10,0,0,0)
	sound_effects = true
	#Really need to make sure was an asteroid.
	if Globals.asteroid_search and body.name == "LargeAsteroid" and portal_timer <= 0:
		#print("E: ",body.name)
		Globals.asteroid_search = false
		Globals.active_asteroid = body
		Universe.update_asteroid_belt = true
	
		if not Globals.first_asteroid :
			Globals.first_asteroid = true
			Globals.activate_display_thought(Globals.first_asteroid_text)
	# Temp code for comsuming resources
	
	
func _on_Player_body_exited(_body):
	sound_effects = false
	if dist_moved > 0.4 :
		if (sound_effect_mode == 2) or (sound_effect_mode == 0) :
			sound_effect_mode += 1

func _on_PortalSensor_area_entered(area):
	if not Globals.first_portal :
		Globals.first_portal = true
		Globals.activate_display_thought(Globals.first_portal_text)
	get_node("PortalChargeEffect").play()
	area.get_parent().activated = true
	if area.get_parent().type == area.get_parent().COPPER_PORTAL :
		Globals.copper_portal = true
	if area.get_parent().type == area.get_parent().IRON_PORTAL :
		Globals.iron_portal = true
	pass # Replace with function body.


func _on_PortalSensor_area_exited(area):
	area.get_parent().activated = false
	Globals.portal_duration = 0
	if area.get_parent().type == area.get_parent().COPPER_PORTAL:
		Globals.copper_portal = false
	if area.get_parent().type == area.get_parent().IRON_PORTAL :
		Globals.iron_portal = false

func _on_ResourceSensor_area_entered(_area):
	if not Globals.first_ore :
		Globals.first_ore = true
		Globals.activate_display_thought(Globals.first_ore_text)

func _on_PlanetSensor_area_entered(area):
	if Globals.active_planet == area.get_parent() :
		in_orbit = true
		visible = false
		$Camera2D.current = false
		area.get_parent().get_node("Camera2D").current = true
		Globals.active_camera = area.get_parent().get_node("Camera2D")
		#print(area.get_parent().get_node("MoonPath"))
		var sp = Sprite.new()
		sp.texture = $CollisionShape2D/PlayerImg.texture
		area.get_parent().get_node("MoonPath").get_node("Moon").add_child(sp)
		var planet_scale = area.get_parent().get_parent().scale
		sp.scale = $CollisionShape2D/PlayerImg.scale / planet_scale
		Globals.game_end = true
		Globals.activate_display_thought(Globals.end_text)
