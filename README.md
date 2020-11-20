# GDC_GameOff_2020

Used to manage the game being built for Game Off 2020 being built in Godot version 3.2.2.

In this game you are a small rock on an asteroid with big ambitions. You will move around and gather more rock to yourself in the goal of becoming of moon.
<br>
<br>
Movement will be by moving the larger asteroids the player is on rather than the player directly.  Will work to try and have objects have gravity fields that can affect how the player moves.  So smaller asteroids the player won't cling to as easily as larger asteroids.  Also as the player shots through space the other objects can affect the path the player takes.
<br>
The player can pick up three main types of of things to grow larger and they affect how the player interacts with things in the world:
<br>
1. Copper - Works well with electricity, gives access to certain electrical based propulsion systems to fly to new locations.   Higher percent is copper the further you can travel.<br>
2. Iron - Magnetic systems for travel.  More iron, further can travel using those systems.<br>
3. Rock - Protects the outside of the asteroid, if it is gone then starts loosing internals like Iron and Copper.<br>
<br>
Additionally, there are rare items that add bonuses to the base items:<br>
1. Gold - Adds a multiple to copper boost.<br>
2. Alnico (is an iron alloy with aluminum and nickel) - Adds multiple to iron boost. This could be something where as you pick up aluminum and nickel it automatically combines with the iron to form the alloy.<br>
3. Gems: Reinforces the rock shell to boost the armor protection.<br>
<br>
Things that could hurt the player: <br>
1. Other asteroids flying through space. <br>
2. Perhaps aliens out to mine asteroids for materials. <br>
<br>
Moving between asteroids will cost some amount of the the gathered resources, so encourages trying to gather as much as possible at one asteroid before moving on.