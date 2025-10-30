extends Control


func _ready() -> void:
	$Music.play()

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/level/level_1.tscn")



func _on_audio_stream_player_2d_finished() -> void:
	$Music.play()
