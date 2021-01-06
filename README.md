# Version 1 built for GDC_GameOff_2020
# Version 2 built for virtual MAGFest 2021

Game built using: Godot version 3.2.2

In this game you are a small rock wandering space with big ambitions. You will seek out and find large asteroids around you...well more they will pull you to them if you get too close.  You will be able to rotate these large asteroids to move yourself around to gather more resources in the goal of becoming of moon.
<br>
<br>
Player movement is now possible via three different methods:
<br>
First, is by rotating the larger asteroids the player is on causing the player to move.  This seems a little counter intuitive at first as you move in the opposite direction of the rotation.  
<br>
Second, is by directly moving the player by holding the mouse button and using the mouse pointer to move the player that direction.  While effective, this uses up resources, so must be used sparingly.
<br>
<br>
Third, is by using a pair of portals on the large asteroids to move across the wide expanse of space. The longer you sit in the prortal the more power it will provide when you press the up arrow key to fly out into space.  One portal bases its strength off your copper composition, the other off your iron composition.  Once you reach moon size you gain an addtional power boost from the portals as well.
<br>
<br>
The player can pick up three main types of of resources to grow larger and they affect how the player interacts with things in the world:
<br>
1. Copper - Works well with electricity, gives greater power to electrical based portal systems to fly to new locations.   Higher percent is copper the further you can travel.
<br>
2. Iron - Magnetic systems for travel.  More iron, further can travel using those systems.
<br>
3. Rock - Protects the outside of the asteroid, if it is gone then starts loosing internals like Iron and Copper. <This feature not fully implemented yet>
<br>
There are three progress bars at the top left of the screen to show you the present composition of your asteroid.  The first is rock, second iron, and third is copper.
<br>
<br>
Additionally, there are rare items that add bonuses to the base items:
<br>
1. Gold - Adds a multiple to copper boost.
<br>
2. Alnico (is an iron alloy with aluminum and nickel) - Adds multiple to iron boost.
<br>
3. Gems: Reinforces the rock shell to boost the armor protection by adding a multiplier to it. <Not fully implemented>
<br>
<br>
Things that hurt the player: 
<br>
1. Other asteroids flying through space. There are small asteroids that will approach you on the large asteroids and try and run into you.  They are jealous of what you are trying to do.  There are three types, with each type reducing a different resource.  If you dodge the attack, the enemy will crash into the large asteroid and may leave a pile of rubble you can pick up instead that will give resources based on the type that would have been stolen.
<br>
2. Perhaps aliens out to mine asteroids for materials. <Not fully implemented>
<br>
<br>
Becoming a moon:
Once you reach a certain size, there is a progress bar at the bottom of the screen to let you know when this occurs.  To help find a planet to orbit around there is an image of the sun and an arrow pointing the direction it is in.  Additionally the portals will glow white when the only thing the direction they point is the sun.  There is one of three planets you can end up in orbit around.  At present it does not matter which planet you become the moon for.