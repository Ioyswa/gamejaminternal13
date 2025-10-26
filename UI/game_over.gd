extends Control


func _on_button_pressed() -> void:
	match Data.previous_level:
		2:
			get_tree().change_scene_to_file("res://scene/level/level_2.tscn")
		3:
			get_tree().change_scene_to_file("res://scene/level/level_3.tscn")
