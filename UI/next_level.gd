extends Control



var story = {
	1: "Setelah shift nya berakhir, Navi segera menyelinap keluar \nmelalui pintu belakang perusahaan.",
	2: "Navi berhasil melewati penjaga pintu belakang perusahaan,\n satu langkah lebih dekat dengan kebebasan yang ia dambakan"
}

func _ready() -> void:
	match Data.previous_level:
		1:
			$StoryLabel.text = story[1]
		2:
			$StoryLabel.text = story[2]

func _on_next_level_pressed() -> void:
	match Data.previous_level:
		1:
			$StoryLabel.text = story[1]
			get_tree().change_scene_to_file("res://scene/level/level_2.tscn")
		2:
			get_tree().change_scene_to_file("res://scene/level/level_3.tscn")


func _on_button_pressed() -> void:
	match Data.previous_level:
		1:
			get_tree().change_scene_to_file("res://scene/level/level_2.tscn")
		2:
			get_tree().change_scene_to_file("res://scene/level/level_3.tscn")
