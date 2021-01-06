extends Control


# Declare member variables here. Examples:
var play_fx_snd = false

# Used to preserve the state of the slider between scene changes.
var current_value = db2linear(Globals.fx_volume) 

# Called when the node enters the scene tree for the first time.
func _ready():
	#$FXSlider.value = 100.0*(Globals.fx_volume + 80.0)/104.0
	$FXSlider.max_value = db2linear(Globals.MAX_VOLUME)
	$FXSlider.min_value = 0
	$FXSlider.value = current_value
	play_fx_snd = true

func _on_FXSlider_value_changed(value):
	Globals.fx_volume = linear2db(value)
	$FXTestVolumeSnd.volume_db = Globals.fx_volume
	print(Globals.fx_volume)
	if play_fx_snd and not $FXTestVolumeSnd.playing:
		$FXTestVolumeSnd.play()
	elif play_fx_snd and $FXTestVolumeSnd.playing and $FXTestVolumeSnd.get_playback_position() > 0.5 :
		$FXTestVolumeSnd.stop()
