extends Node2D

func _ready() -> void:
	Data.previous_level = 1


func _on_triger_win_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Data.previous_level = 1
		get_tree().change_scene_to_file("res://UI/next_level.tscn")
