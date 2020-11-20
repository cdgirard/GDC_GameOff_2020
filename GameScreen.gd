extends Node2D

onready var Background = preload("res://game_background/GameBackground.tscn")
onready var Player = preload("res://player/Player.tscn")
onready var LargeAsteroid = preload("res://LargeAsteroid/LargeAsteroid.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var bkg = Background.instance()
	add_child(bkg)
	var largeAsteroid = LargeAsteroid.instance()
	Globals.active_asteroid = largeAsteroid
	add_child(largeAsteroid)
	var player = Player.instance()
	player.position.y = -400
	add_child(player)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
