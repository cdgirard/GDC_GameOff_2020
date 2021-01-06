extends Button

func _on_Button_pressed():
	self.text = "Clicked"
	pass # Replace with function body.


func _on_Button_mouse_entered():
	self.add_color_override("font_color_hover", Color(0,0,0));
	pass # Replace with function body.
