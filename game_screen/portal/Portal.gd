extends Node2D

enum {COPPER_PORTAL, IRON_PORTAL}

var activated = false

var CLOSE_DIST = 3000
# Declare member variables here. Examples:
var my_asteroid
var type = IRON_PORTAL


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var timer = 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): # instead of one closest all within a certain dir
	if activated :
		get_node("PortalPower").value = Globals.portal_duration #Should only be if active.
	else :
		get_node("PortalPower").value = 0
	var intensity = 0.5
	var hue_level = 0.0
	var planet_intensity_level = 0.0
	if not Globals.asteroid_search and my_asteroid == Globals.active_asteroid :
		var look_dir = (global_position - my_asteroid.global_position).normalized()
		var target = Universe.determine_gravity_source_in_dir(global_position,look_dir)
		#I bet if we are in the process of adding and removing asteroids this could cause target
		#to go away on a fresh landing.  This should only be for one or two game loops, so should
		#fine to just use a conditional to cover this rare case rather than trying to get
		#all the timings right.
		if target != null :
			var target_dist = target.global_position.distance_to(global_position)
			var target_dir = (target.global_position - global_position).normalized()
			var dir_diff = look_dir.distance_to(target_dir)
			#Compute intensity level first for the colors
		
			if target_dist < CLOSE_DIST :
				intensity = 1.0
			else :
				intensity = 1.0 - ((target_dist - CLOSE_DIST)/(Universe.MAX_DIST - CLOSE_DIST))
			intensity = max(0.5,intensity)
			#Next figure out how much color to show
			hue_level = 1.0 - dir_diff
			if hue_level <= 0 : #If the object is the other direction then reduce intensity
				intensity = min(0.4,intensity)
			hue_level = max(0.1,hue_level)
			if hue_level >= 0.5 :
				hue_level = sqrt(hue_level)
		#We are moon ready
		if Universe.player != null and Universe.player.scale_size[4] <= Globals.get_total_resources() :
			#No asteroids in direction of portal see if it points at the sun
			if hue_level < 0.5 : 
				look_dir = (global_position - my_asteroid.global_position).normalized()
				var target_pos = Vector2(0,0) # Sun is at the center - bad that this is hardcoded.
				var target_dir = (target_pos - global_position).normalized()
				var dir_diff = look_dir.distance_to(target_dir)
				planet_intensity_level = 1.0 - dir_diff
				if planet_intensity_level >= 0.5 :
					planet_intensity_level = sqrt(planet_intensity_level)
#		timer -= delta
#		if timer < 0 :
#			print("diff: ",dir_diff," bright: ",hue_level, " intensity: ",intensity," dist: ",target_dist)
#			timer = 1
	if hue_level > planet_intensity_level :
		if type == IRON_PORTAL :
			$Animation.set_modulate(Color(0,hue_level,hue_level,intensity))
		if type == COPPER_PORTAL :
			$Animation.set_modulate(Color(hue_level,hue_level/2,0,intensity))
	else :
		$Animation.set_modulate(Color(1.0,1.0,1.0,planet_intensity_level))
		#print("Modulate: ",$UpConeV4.modulate)
		
#	pass
