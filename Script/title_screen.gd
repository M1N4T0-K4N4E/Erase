extends Control


func _on_startbtn_pressed():
	get_tree().change_scene_to_file("res://Asset/in_game_screen.tscn")
	pass # Replace with function body.
	
func _on_quitbtn_pressed():
	get_tree().quit()
	pass # Replace with function body.

func _on_loadbtn_pressed() -> void:
	#get_tree().change_scene_to_file()
	pass # Replace with function body.
