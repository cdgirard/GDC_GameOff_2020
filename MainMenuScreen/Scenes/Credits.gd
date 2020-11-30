extends Node2D

var lab = preload("res://MainMenuScreen/Scenes/CreditText.tscn")
var lines = [
"AsterRoll",
"Game Idea: Ryan Carroll, Joseph  Kunsman, and Dudley Girard - Game Dev Club",
"Enemy Asteroid: Author: Phaelax - Opengameart.org",
"Game and Menu Screen Background Images: Author: Luminous Dragon Games - Opengameart.org",
"Player Images: Author: GameArtForge - Opengameart.org",
"Large Asteroids: Author: Jasper - Opengameart.org",
"Rock rollin on rock sound effect: Author: Dmunk - freesound.org",
"Background Music While Rolling: Jan Molina - Game Dev Club",
"Background Music While in Space: Author: Florianreichelt - freesound.org",
"Menu Screen - Tyler Forrester - Game Dev Club",
"Resource Gathering: Dudley Girard and Joseph Kunsman - Game Dev Club",
"Player Movement and Controls: Dudley Girard - Game Dev Club",
"Game Screen Background: Dudley Girard - Game Dev Club",
"Asteroid Field Creation: Dudley Girard - Game Dev Club",
"Transport Portals: Dudley Girard and Ryan Carroll",
"Equinox Typeface Font: Author: Dafont - Dafontfree.io",
"Star: Author: Écrivain - Opengameart.org"
]
var frameCount = 0
var count = 0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var l = lab.instance()
	l.get_node("Label").text = lines[0]
	l.set_position(Vector2(40,400))
	add_child(l)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	frameCount += 1
	if (frameCount%60 == 0 && count < lines.size()-1):
		count += 1
		var l = lab.instance()
		l.get_node("Label").text = lines[count]
		l.set_position(Vector2(40,400))
		l.get_node("Label").autowrap = true
		add_child(l)
		
	#print(frameCount)
	pass
