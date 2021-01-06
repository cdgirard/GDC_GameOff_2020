extends Node

# How much louder or quieter to make the music
#   THIS ONLY STORES THE CURRENT VOLUME AS SET BY THE SLIDER IN SETTINGS MENU.
#   TO CHANGE THE MUSIC VOLUME, USE  MusicPlayer.set_master_volume().
var music_volume = -17.0
# How much louder or quieter to make the fx
#   For now, this still directly controls sfx volume, but ideally we should
#   use a SFX bus.  Leaving it alone for now.
var fx_volume = -15.0
#Affects how much you gain or loose resources
var difficulty = 1

# Constant for the maximum volume (used for Settings menu sliders)
#   MAX_VOLUME should be a global volume cap. Default volume (0 db) is too loud for
#   pretty much anyone, so we might as well define our own max volume.
#   MIN_VOLUME is just a more clear way to represent NO volume.
const MAX_VOLUME = -15
const MIN_VOLUME = -80

# Set to true if want initial message displayed
var play_start = false
#Set to true if you want tutorial messages to display while playing
var show_tutorial = false

#Used to determine the game has ended
var game_end = false

# Set to true after a tutorial message has displayed
#change this to a dictionary then can add here and update all over the place
#as needed.
var first_ore = false
var first_asteroid = false
var first_attacked = false
var first_rubble = false
var first_portal = false
var reached_moonsize = false

#Helpful messages to the player shown in PlayerThoughtsLabel
var end_text = "i have become\na moon!!!\ni am happy...........\nso very happy now..."
var start_text = "so small...\nso lonely...\ni wish to become...\na moon ! ! !"
var first_ore_text = "i crushed this...\nand grew...\ni must find more ! ! !"
var first_asteroid_text = "so large...\nit looks like i can use\nthe left and right\narrow keys to\nrotate it and move..."
var first_attacked_text = "ouch ! that hurt...\nand i got smaller too...\ni need to avoid these\nsmall asteroids..."
var first_rubble_text = "that impact left\na small pile of rubble\ni bet i can collect it..."
var first_portal_text = "interesting...if i wait\nfor this to charge\nand use the up arrow i\ncan fly into space!"
var player_movement_text = "i am getting bigger...\ni can start using the left mouse button\nto manually move around ! ! !"
var first_spaceship_text = "that thing looks scary !\ni should keep away from those mining ships\nbefore i become ore myself ! ! !"
var player_reached_moonsize_text = "i've grown big...\nbig enough to be a\nmoon...now i need\na home...."
var thought_text = ""
var display_thought = false

var active_asteroid
var asteroid_motion = false
var asteroid_direction = 0
var asteroid_search = false

var active_planet
var planet_search = false

var MOON_SIZE = 2400
var rock_gathered = 0
var iron_gathered = 0
var copper_gathered = 0

var rock_multiplier = 1
var iron_multiplier = 1
var copper_multiplier = 1

var rock_composition = 0
var iron_composition = 0
var copper_composition = 0

var copper_portal = false
var iron_portal = false
var portal_duration = 0

var active_camera

var enemy_pool = []
var rubble_pool = []

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	reset()
	rng.randomize()
	update_gathered(1,1,1,0,0,0) #This uses the default difficulty at startup.
	difficulty = 3 #Default setting
	set_tutorial_option(show_tutorial)

func reset() :
	planet_search = false
	asteroid_search = false
	asteroid_motion = false
	display_thought = false
	first_ore = false
	first_asteroid = false
	first_attacked = false
	first_rubble = false
	first_portal = false
	reached_moonsize = false
	game_end = false
	rock_gathered = 0
	iron_gathered = 0
	copper_gathered = 0

	rock_multiplier = 1
	iron_multiplier = 1
	copper_multiplier = 1

	rock_composition = 0
	iron_composition = 0
	copper_composition = 0

func get_total_resources() :
	return rock_gathered + iron_gathered + copper_gathered

func get_copper_boost() :
	return copper_composition*copper_multiplier
	
func get_iron_boost() :
	return iron_composition*iron_multiplier
	
func activate_display_thought(text) :
	display_thought = true
	thought_text = text
	get_tree().paused = true

func set_tutorial_option(value) :
	show_tutorial = value
	first_ore = not value
	first_asteroid = not value
	first_attacked = not value
	first_rubble = not value
	first_portal = not value
	reached_moonsize = not value

func get_enemy_from_pool() :
	if enemy_pool.size() > 0 :
		var pool_enemy = enemy_pool[0]
		pool_enemy.reset()
		enemy_pool.remove(0)
		return pool_enemy
		
func get_rubble_from_pool() :
	if rubble_pool.size() > 0 :
		var pool_rubble = rubble_pool[0]
		pool_rubble.reset()
		rubble_pool.remove(0)
		return pool_rubble

#This code looks like it could be refactored.
func update_gathered(rock,iron,copper,gems,alnico,gold) :
	if rock >= 0 :
		rock_gathered += rock*difficulty
	else :
		rock_gathered += rock*(1.0 + 1.0/difficulty)
	rock_gathered = max(0,rock_gathered)
	
	if iron >= 0 :
		iron_gathered += iron*difficulty
	else :
		iron_gathered += iron*(1.0 + 1.0/difficulty)
	iron_gathered = max(0,iron_gathered)
	
	if copper >= 0 :
		copper_gathered += copper*difficulty
	else :
		copper_gathered += copper*(1.0 + 1.0/difficulty)
	copper_gathered = max(0,copper_gathered)
	
	if gems >= 0:
		rock_multiplier += gems*(1.0 + difficulty/8.0)
	else :
		rock_multiplier += gems*(1.0 + 1.0/difficulty)
	rock_multiplier = max(0,rock_multiplier)
	
	if alnico >= 0 :
		iron_multiplier += alnico*(1.0 + difficulty/8.0)
	else :
		iron_multiplier += alnico*(1.0 + 1.0/difficulty)
	iron_multiplier = max(0,iron_multiplier)
	
	if gold >= 0:
		copper_multiplier += gold*(1.0 + difficulty/8.0)
	else :
		copper_multiplier += gold*(1.0 + 1.0/difficulty)
	copper_multiplier = max(0,copper_multiplier)
	var total = rock_gathered + iron_gathered + copper_gathered
	if total == 0 :
		rock_composition = 0
		iron_composition = 0
		copper_composition = 0
	else :
		#4 on each side
		rock_composition = min(100, compute_composition(rock_gathered,total,rock_multiplier))
		iron_composition = min(100, compute_composition(iron_gathered,total,iron_multiplier))
		copper_composition = min(100,compute_composition(copper_gathered,total,copper_multiplier))
	if Universe.player != null :
		Universe.player.set_deferred("mass", max(1,total/10))
	if total > MOON_SIZE and not Globals.reached_moonsize :
		Globals.reached_moonsize = true
		Globals.activate_display_thought(Globals.player_reached_moonsize_text)
	#print(rock_gathered, " ",iron_gathered, " ",copper_gathered, " ",rock_multiplier, " ",copper_multiplier," ",iron_multiplier)

#We could eventually make the gold, gems, etc the multiplier here.
func compute_composition(value,total, multiplier) :
	return (4 + (value*92 / total))*multiplier
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
