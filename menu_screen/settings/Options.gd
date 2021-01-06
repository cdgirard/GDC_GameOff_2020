extends Control


# Declare member variables here. Examples:

# Called when the node enters the scene tree for the first time.
func _ready():
	$TutorialCheckBtn.pressed = Globals.show_tutorial
	$StartCheckBtn.pressed = Globals.play_start


func _on_TutorialCheckBtn_pressed():
	Globals.set_tutorial_option($TutorialCheckBtn.pressed)


func _on_StartCheckBtn_pressed():
	Globals.play_start = $StartCheckBtn.pressed
