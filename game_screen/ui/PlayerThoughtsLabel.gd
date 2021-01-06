extends RichTextLabel

const CHAR_DELAY = 0.1
const CHAR_DELAY_LONG = 0.33
var text_count = 0
var char_timer = CHAR_DELAY

# Called when the node enters the scene tree for the first time.
func _ready():
	$SoundofThoughts.volume_db = Globals.fx_volume
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.display_thought : # Slowly add txt to PlayerThoughtsLabel
		text = Globals.thought_text.left(text_count)
		if not $SoundofThoughts.playing :
			$SoundofThoughts.play()
		char_timer -= delta
		if char_timer <= 0:                   # If the timer runs out...
			$SoundofThoughts.stop()           #  stop the sound
			text_count += 1                   #  increment text count
			if text_count+1 < Globals.thought_text.length() and Globals.thought_text[text_count] == '.':
				char_timer = CHAR_DELAY_LONG  # set a long delay on period
			else:
				char_timer = CHAR_DELAY       # set a normal delay otherwise
		if text_count == Globals.thought_text.length()+1:
			Globals.display_thought = false
			$SoundofThoughts.stop()
			text_count = 0
			char_timer = 2
	else :
		if char_timer >= 0 :
			char_timer -= delta
		else :
			text = ""
			get_tree().paused = false
