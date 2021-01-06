extends Node2D

onready var Player = preload("res://game_screen/player/Player.tscn");
onready var takeOff = get_node("TakeOff")
onready var fireShot = get_node("FireShot")
onready var aimingLaser = get_node("AimingLaser")
onready var missle = preload("res://game_screen/space_ship/missle/Missle.tscn")
onready var firstTimeOut = 1


# Declare member variables here. Examples:
var direction = 1
var oldDirection = 0
onready var firstTarget = 0
onready var targeting = 0
onready var shotFired = false


# Called when the node enters the scene tree for the first time.
func _ready():
	aimingLaser.add_point(Vector2(0,0))
	takeOff.set_wait_time(5)
	fireShot.set_wait_time(3)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position += Vector2(direction*2.5,0)
	if targeting == 1:
		if firstTarget == 0:
			firstTarget = 1
		else:
			aimingLaser.remove_point(1)
		aimingLaser.add_point(Universe.player.global_position - global_position,1)
	pass
	
func createEntity(dir,glo):
	direction = dir
	global_position = glo
	if dir == 1:
		$Area2D/AnimatedSprite.flip_h = true
	pass


func _on_Area2D_area_entered(area):
	if area.name == "SpaceShipSensor" :
		if 800 < Globals.get_total_resources() && Globals.get_total_resources() >= 2400:
			if shotFired == false:
				targeting = 1
				oldDirection = direction
				direction = 0
				takeOff.start()
				fireShot.start()
				shotFired = true
				get_node("AimingLaser2").play()
	pass # Replace with function body.


func _on_TakeOff_timeout():
	if firstTimeOut == 0:
		get_node("Area2D/AnimatedSprite").visible = false
		get_node("Area2D/CollisionShape2D").set_deferred("disabled", true)
		queue_free()
	direction = oldDirection
	direction = direction * 4
	firstTimeOut = 0
	
	pass # Replace with function body.


func _on_FireShot_timeout():
	fireShot.stop()
	targeting = 0
	aimingLaser.remove_point(1)
	var miss = missle.instance()
	miss.set_direction(Universe.player.global_position - global_position)
	miss.global_position = global_position
	get_tree().get_root().get_node("Universe").add_child(miss)
	pass # Replace with function body.
