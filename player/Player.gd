extends RigidBody2D

enum SIZE {small, medium, large}

# Declare member variables here. Examples:
var MAX_GRAVITY = 100
var velocity = Vector2()
var gravity = Vector2()
export var speed = 100
var prev_position
var roll_mode = false
var roll_timer = 0

func move():
	pass
#	if Input.is_action_pressed("ui_right"):
#		velocity.x += .1
#	elif Input.is_action_pressed("ui_left"):
#		velocity.x -= .1
#	if Input.is_action_pressed("ui_down"):
#		velocity.y += .1
#	elif Input.is_action_pressed("ui_up"):
#		velocity.y -= .1
	#velocity = velocity.normalized() * speed
	#move_and_collide(velocity)

# Called when the node enters the scene tree for the first time.
func _ready():
	velocity = Vector2(0,0)
	get_node("MoveOnAsteroidSound").play()
	prev_position = position
	#print(velocity)
	pass
		
func _process(delta):
	var pos_change = (prev_position - position)
	var dist_moved = pos_change.length()

	prev_position = position
	if dist_moved < 0.05 and not roll_mode:
		roll_timer = 2.0
		print("Here")
		add_torque(200.0)
		roll_mode = true
		Globals.asteroid_motion = false
	elif dist_moved > 0.2 and roll_mode :
		print(dist_moved)
		roll_timer = 0
		print("Stop Roll Mode")
		roll_mode = false
		add_torque(-applied_torque)
	elif dist_moved > 0.1 and not roll_mode:
		if Globals.asteroid_direction == 1 :
			angular_velocity = -5
		elif Globals.asteroid_direction == -1 :
			angular_velocity = 5

	
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
	#print(angle)
	gravity.x = -angle.x * MAX_GRAVITY * delta
	gravity.y = -angle.y * MAX_GRAVITY * delta
	#print(velocity)
	self.linear_velocity += gravity
	#velocity += gravity
	move()
