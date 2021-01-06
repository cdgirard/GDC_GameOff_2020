extends Path2D

# Declare member variables here. Examples:
var asteroids = {}
var spacing = 0.05
var speed = 0.0001

#Timer to test changes to asteroids in ast_path
var timer = 5
var index = 0
var update_list = ["A", "B", "C", "D", "E"]

# Called when the node enters the scene tree for the first time.
func _ready():
	add_asteroid($PathFollow2DA,"A",0)
	add_asteroid($PathFollow2DB,"B",0)
	add_asteroid($PathFollow2DC,"C",0)
	add_asteroid($PathFollow2DD,"D",0)
	add_asteroid($PathFollow2DE,"E",0)
	pass # Replace with function body.

func set_spacing(space) :
	spacing = space
	$PathFollow2DA.unit_offset = $PathFollow2DC.unit_offset - spacing*2
	$PathFollow2DB.unit_offset = $PathFollow2DC.unit_offset - spacing
	$PathFollow2DD.unit_offset = $PathFollow2DC.unit_offset + spacing
	$PathFollow2DE.unit_offset = $PathFollow2DC.unit_offset + spacing*2

func shift(unit_offset_adj) :
	$PathFollow2DA.unit_offset += unit_offset_adj
	$PathFollow2DB.unit_offset += unit_offset_adj
	$PathFollow2DC.unit_offset += unit_offset_adj
	$PathFollow2DD.unit_offset += unit_offset_adj
	$PathFollow2DE.unit_offset += unit_offset_adj

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not Globals.display_thought :
		$PathFollow2DA.set_unit_offset($PathFollow2DA.get_unit_offset()+speed*delta)
		$PathFollow2DB.set_unit_offset($PathFollow2DB.get_unit_offset()+speed*delta)
		$PathFollow2DC.set_unit_offset($PathFollow2DC.get_unit_offset()+speed*delta)
		$PathFollow2DD.set_unit_offset($PathFollow2DD.get_unit_offset()+speed*delta)
		$PathFollow2DE.set_unit_offset($PathFollow2DE.get_unit_offset()+speed*delta)
		#Test code only
		timer -= delta
		if timer < 0 and scale.x < 2.5:
			timer = 5
			update_asteroids(asteroids[update_list[index]].global_position)
			index += 1

#We should only call this when the player moves asteroids
func update_asteroids(player_loc):
	var data = {}
	data["A"] = player_loc.distance_to($PathFollow2DA.global_position)
	data["B"] = player_loc.distance_to($PathFollow2DB.global_position)
	data["C"] = player_loc.distance_to($PathFollow2DC.global_position)
	data["D"] = player_loc.distance_to($PathFollow2DD.global_position)
	data["E"] = player_loc.distance_to($PathFollow2DE.global_position)
	var slot = "A"
	for dist in data :
		if data[slot] > data[dist] :
			slot = dist
	match slot :  # A   B   C   D   E
		"A" :
			var tmp1 = asteroids["D"]
			var tmp2 = asteroids["E"]
			move_asteroid($PathFollow2DC,$PathFollow2DE,"C","E")  # C moves to E
			move_asteroid($PathFollow2DB,$PathFollow2DD,"B","D") # B moves to D
			move_asteroid($PathFollow2DA,$PathFollow2DC,"A","C") # A moves to C
			add_asteroid($PathFollow2DB,"B",-spacing*2) #Create a new B and update B's Offset
			add_asteroid($PathFollow2DA,"A",-spacing*2) #Create a new A and A's offset
			tmp1.queue_free()
			tmp2.queue_free()
		"B" :
			var tmp1 = asteroids["E"]
			move_asteroid($PathFollow2DD,$PathFollow2DE,"D","E") # D moves to E
			move_asteroid($PathFollow2DC,$PathFollow2DD,"C","D") # C moves to D
			move_asteroid($PathFollow2DB,$PathFollow2DC,"B","C") # B moves to C
			move_asteroid($PathFollow2DA,$PathFollow2DB,"A","B") # A moves to B
			add_asteroid($PathFollow2DA,"A",-spacing) #Create a new A and update A's Offset
			tmp1.queue_free()
		"C" : #Right in the middle so do nothing
			pass
		"D" :
			var tmp1 = asteroids["A"]
			move_asteroid($PathFollow2DB,$PathFollow2DA,"B","A") #B moves to A
			move_asteroid($PathFollow2DC,$PathFollow2DB,"C","B") #C moves to B
			move_asteroid($PathFollow2DD,$PathFollow2DC,"D","C") #D moves to C
			move_asteroid($PathFollow2DE,$PathFollow2DD,"E","D") #E moves to D
			add_asteroid($PathFollow2DE,"E",spacing) #Create new E and update E's offset
			tmp1.queue_free()
		"E" :
			var tmp1 = asteroids["A"]
			var tmp2 = asteroids["B"]
			move_asteroid($PathFollow2DC,$PathFollow2DA,"C","A")  #C moves to A
			move_asteroid($PathFollow2DD,$PathFollow2DB,"D","B")  #D moves to B
			move_asteroid($PathFollow2DE,$PathFollow2DC,"E","C")  #E moves to C
			add_asteroid($PathFollow2DD,"D",spacing*2)  #Create new D and update D's offset
			add_asteroid($PathFollow2DE,"E",spacing*2)  #Create new E and update D's offset
			tmp1.queue_free()
			tmp2.queue_free()
			
#Why are all asteroids initially a bit too large
func add_asteroid(path,slot,unit_offset_adj) :
	asteroids[slot] = Universe.create_new_asteroid()
	path.add_child(asteroids[slot])
	asteroids[slot].my_scale = Universe.asteroid_scale
	
	asteroids[slot].scale = Vector2(Universe.asteroid_scale/scale.x,Universe.asteroid_scale/scale.y)
	path.unit_offset += unit_offset_adj

func move_asteroid(from_path,to_path,from_slot,to_slot) :
	to_path.remove_child(asteroids[to_slot])
	from_path.remove_child(asteroids[from_slot])
	to_path.add_child(asteroids[from_slot])
	to_path.unit_offset = from_path.unit_offset
	asteroids[to_slot] = asteroids[from_slot]
	
func update_asteroid_scale() :
	var res_scale = Universe.asteroid_scale
	for slot in asteroids :
		if asteroids[slot] != Globals.active_asteroid :
			#var ast_scale = Vector2(Universe.asteroid_scale,Universe.asteroid_scale)
			var ast_scale = Vector2(res_scale,res_scale)
			asteroids[slot].scale = Vector2(ast_scale.x/scale.x,ast_scale.y/scale.y)
			asteroids[slot].my_scale = res_scale
			for p in asteroids[slot].get_node("ResourcePoints").get_children() :
				if p.get_child_count() > 0 :
					p.get_child(0).scale = Vector2(res_scale/12,res_scale/12)
				#print("Update Res Node Scale: ",p.scale)
			#belt.asteroids[slot].scale = Vector2(asteroid_scale,asteroid_scale)
			#print(asteroids[slot].scale)

#First see if I can override it so I can use it myself
#Is supposed to multiple the current scale by the ratio vector
func apply_scale(ratio) :
	scale *= ratio
	#Cancel the scaling on the asteroid.
	#$PathFollow2DA.Asteroid.scale /= ratio
	#for node in get_children() :
	#	node.apply_scale(ratio)
	pass
