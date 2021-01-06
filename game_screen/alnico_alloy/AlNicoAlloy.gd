extends Area2D


var my_asteroid = null


# Called when the node enters the scene tree for the first time.
func _ready() :
	$CollectSoundEffect.volume_db = Globals.fx_volume

# Called every frame. 'delta' is the elapsed time since the previous frame.
# warning-ignore:unused_argument
func _process(delta):
	pass

func _on_AlNicoAlloy_area_entered(area):
	if area.name == "ResourceSensor" :
		Globals.update_gathered(0,0,0,0,my_asteroid.my_scale*0.04,0)
		get_node("CollectSoundEffect").play()
		get_node("Explosion").emitting = true
		get_node("Sprite").visible = false
		get_node("CollisionShape2D").set_deferred("disabled", true)
