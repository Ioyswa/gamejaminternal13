extends Node2D

func _ready() -> void:
	Data.previous_level = 3
	$Player/AudioStreamPlayer2D.play()


func _on_win_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://UI/end_screen.tscn")


func _on_audio_stream_player_2d_finished() -> void:
	$Player/AudioStreamPlayer2D.play()
