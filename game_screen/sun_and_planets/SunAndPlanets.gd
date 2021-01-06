extends Node2D

#We will have about 5-10 active asteroids.  As the player moves forward or backward we
#simply move some asteriods to the front or back to give the illusion of an infinite field.

#We keep 3-5 planets in permanent orbit around the sun, as the player gets larger and stronger
#multiplier it will allow them to travel further and further till they can reach and oribit one of the planets.
#Use Path 2D to setup the line follow for when the player gets close enough can also shrink the player
#by zooming out, but keep the planet the same size so the player doesn't look huge compared to it.

var planets = []

# Called when the node enters the scene tree for the first time.
func _ready():
	planets.append($PlanetPath1/Planet)
	planets.append($PlanetPath2/Planet)
	planets.append($PlanetPath3/Planet)
	




