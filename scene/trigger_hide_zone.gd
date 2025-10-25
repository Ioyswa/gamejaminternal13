extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.is_in_hiding_zone = true


func _on_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
