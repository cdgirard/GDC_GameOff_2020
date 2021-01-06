extends Control


#Length of time to play the test music
var test_play_time = 4
var play_test_music = false

# Used to preserve the state of the slider between scene changes.
var current_value = db2linear(MusicPlayer.get_master_volume())

# Called when the node enters the scene tree for the first time.
func _ready():
	# The range defined here is essentially 0 to 1 so we can use Godot's linear2db function to 
	# correctly convert the slider's value (linear) to db (logarithmic).
	#
	# If we make the max_value = 1 however, the slider would be -80 to 0 db, and 0 db
	# is much louder than anyone would want. 
	#
	# Instead, we make max_value the linear equivalent of Globals.MAX_VOLUME.
	# This means the two slider's steps will not line up since max SFX and Music
	# volume are -15 and -17, respectively, so their scales are slightly different. 
	$MusicSlider.max_value = db2linear(Globals.MAX_VOLUME)
	$MusicSlider.min_value = 0
	$MusicSlider.value = current_value
	play_test_music = true

func _process(delta) :
	test_play_time -= delta
	if test_play_time < 0 :
		$MusicTestVolumeSnd.stop()

func _on_MusicSlider_value_changed(value):
	# Sets MusicPlayer volume to value unless value equals the slider minimum.
	var value_db = linear2db(value)
	if !MusicPlayer.is_track_playing(0):
		MusicPlayer.track_play(MusicPlayer.bgm_main_menu, 0)
	if value_db >= Globals.MIN_VOLUME+1:
		Globals.music_volume = value_db
		MusicPlayer.set_master_volume(value_db)
	else:
		# Just stop the music if you set the value low enough so we aren't
		# needlessly processing music in the background.
		MusicPlayer.set_master_volume(Globals.MIN_VOLUME)
		MusicPlayer.stop_all()
	print(MusicPlayer.get_master_volume())

#func _on_MusicSlider_value_changed(value):
#	Globals.music_volume = 104*(value/100.0) - 80 #So at 50 plays at default value.
#	$MusicTestVolumeSnd.volume_db = Globals.music_volume
#	print($MusicTestVolumeSnd.volume_db)
#	if play_test_music :
#		$MusicTestVolumeSnd.play()
#		test_play_time = 4
