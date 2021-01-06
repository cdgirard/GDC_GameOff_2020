extends Node

const _MIN_VOLUME = -80
const _MAX_VOLUME = Globals.MAX_VOLUME

# Preloaded background music tracks
const bgm_main_menu = preload("res://music/assets/music_menu-theme1-3.ogg")
const bgm_default = preload("res://music/assets/music_rolling-theme.ogg")
const bgm_dynamic_layer01 = preload("res://music/assets/music_dn_space_layer01.ogg")
const bgm_dynamic_layer02 = preload("res://music/assets/music_dn_space_layer02.ogg")
const bgm_dynamic_layer03 = preload("res://music/assets/music_dn_space_layer03.ogg")
const bgm_empty_space01 = preload("res://music/assets/music_empty-space1.ogg")
const bgm_empty_space02 = preload("res://music/assets/music_empty-space2.ogg")

# Playback positions of the tracks 
var _pause_position = [0,0,0,0]

# Array of AudioStreamPlayers that can be used to play the tracks from
onready var track : Array = [$MusicTrack0, $MusicTrack1, $MusicTrack2, $MusicTrack3]

# The transition AnimationPlayer
onready var _transition = $Transition

# Names of the transition animations (theres probably a nicer way to do this)
const _trans_fade_in = ["FadeInTrack0", "FadeInTrack1", "FadeInTrack2", "FadeInTrack3"]
const _trans_fade_out= ["FadeOutTrack0", "FadeOutTrack1", "FadeOutTrack2", "FadeOutTrack3"]

# Called when the node enters the scene tree for the first time.
func _ready():
	# Sets up the individual tracks by assigning a stream, bus, and volume.
	for i in track.size():
		track[i].stream = null
		track[i].bus = "Music"
		track[i].volume_db = 0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), Globals.music_volume)
	pass


func track_load(track_name, track_index: int):
	# First argument is the track name. Second argument is the track number to play from.
	if not track_index in range(0, track.size()):
		print("track_load: Invalid track index (" + str(track_index) + ")")
		return
	if track_name == null:
		print("set_track_bus: Could not find track '" + track_name + "'")
		return
		
	track[track_index].stream = track_name


func track_start(track_index: int):
	# Starts a track (must have a stream loaded first)
	if not track_index in range(0, track.size()):
		print("track_start: Invalid track index (" + str(track_index) + ")")
		return
	if track[track_index].stream == null:
		print("track_start: No stream specified on track " + str(track_index) + "!")
		return
		
	track[track_index].play(0)


func track_play(track_name, track_index: int):
	# Sets the track AudioStream to one of the preloaded tracks AND plays it
	if not track_index in range(0, track.size()):
		print("track_play: Invalid track index (" + str(track_index) + ")")
		return
	if track_name == null:
		print("track_play: Track " + str(track_name) + " not found!")
		return
		
	track[track_index].stream = track_name 
	track[track_index].play()


func track_stop(track_index: int):
	# Stop a specific track.
	if not track_index in range(0, track.size()):
		print("track_stop: Invalid track index (" + str(track_index) + ")")
		return
		
	track[track_index].stop()


func track_pause(track_index: int):
	# Pause a specific track.
	if not track_index in range(0, track.size()):
		print("track_pause: Invalid track index (" + str(track_index) + ")")
		return
		
	_pause_position[track_index] = track[track_index].get_playback_position()
	track[track_index].stop()


func track_resume(track_index: int):
	# Resume a specific track.
	if not track_index in range(0, track.size()):
		print("track_resume: Invalid track index (" + str(track_index) + ")")
		return
		
	track[track_index].play(_pause_position[track_index])


func stop_all():
	# Stop all tracks.
	for i in track.size():
		track[i].stop()


func pause_all():
	# Pause all tracks and save playback positions.
	for i in track.size():
		_pause_position[i] = track[i].get_playback_position()
		track[i].stop()


func resume_all():
	# Resume all tracks from their respective _pause_position.
	for i in track.size():
		track[i].play(_pause_position[i])


func track_fade_in(track_index: int):
	# Fade in a track (work in progress)
	#  Currently, only track 0 can be faded.
	#  There doesn't appear to be a way to use one animation to animate the
	#  properties of different nodes, so I need to make a separate animation 
	#  for every track...
	if not track_index in range(0, track.size()):
		print("track_fade_in: Invalid track index (" + str(track_index) + ")")
		return
	if track[track_index].stream == null:
		print("track_fade_in: No stream specified on track " + str(track_index) + "!")
		return
		
	#print("Fading in track " + str(track_index))
	track[track_index].volume_db = -80
	track[track_index].play()
	_transition.play(_trans_fade_in[track_index])


func track_fade_out(track_index: int):
	# Fade out a track (work in progress)
	if not track_index in range(0, track.size()):
		print("track_fade_out: Invalid track index (" + str(track_index) + ")")
		return
	if track[track_index].stream == null:
		print("track_fade_out: No stream specified on track " + str(track_index) + "!")
		return
		
	#print("Fading out track " + str(track_index))
	_transition.play(_trans_fade_out[track_index])


func get_track_position(track_index):
	if not track_index in range(0, track.size()):
		print("get_track_position: Invalid track index (" + str(track_index) + ")")
		return
	if track[track_index].stream == null:
		print("get_track_position: No stream specified on track " + str(track_index) + "!")
		return
		
	#print("Track position: " + str(track[track_index].get_playback_position()))
	return track[track_index].get_playback_position()


func is_track_playing(track_index: int):
	# Returns whether or not the specified track is playing.
	if not track_index in range(0, track.size()):
		print("is_track_playing: Invalid track index (" + str(track_index) + ")")
		return
	
	return track[track_index].is_playing()


func set_master_volume(vol):
	# Sets volume of the entire Music bus (clamped to _MAX_VOLUME).
	# Use this to change master music volume instead of Globals.music_volume!
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), min(vol, _MAX_VOLUME))


func set_track_volume(volume, track_index: int):
	# Sets volume of a specific track.
	# Added this for consistency, but if the track volume must be changed frequently
	# you should instead use array subscripting to access the track itself to
	# change volume.  Example: MusicPlayer.track[1].volume_db = -5
	if not track_index in range(0, track.size()):
		print("set_track_volume: Invalid track index (" + str(track_index) + ")")
		return
	
	track[track_index].volume_db = volume


func get_master_volume():
	# Returns current volume of the Music bus.
	return AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))


func set_track_bus(bus: String, track_index: int):
	# Set bus of a specific track.
	# There are currently 3 additional buses for music.
	# If you wish to add more, be sure to send them to Music instead of Master
	# so their volume is governed by the main Music bus.
	if not track_index in range(0, track.size()):
		print("set_track_bus: Invalid track index (" + str(track_index) + ")")
		return
	if AudioServer.get_bus_index(bus) == -1:
		print("set_track_bus: Could not find bus '" + bus + "'")
		return
		
	track[track_index].bus = bus
