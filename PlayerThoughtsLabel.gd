extends RichTextLabel


var start_text = "SO SMALL...\nSO LONELY...\nI WISH TO BECOME...\nA MOON!!!"
var text_count = 0
var char_timer = 0.2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.starting : # Slowly add txt to PlayerThoughtsLabel
		text = start_text.left(text_count)
		char_timer -= delta
		if char_timer <= 0:
			text_count += 1
			char_timer = 0.2
		if text_count == start_text.length() :
			Globals.starting = false
			char_timer = 2
	else :
		if char_timer >= 0 :
			char_timer -= delta
		else :
			text = ""
