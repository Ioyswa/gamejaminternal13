extends Node2D

var is_audio_played = false

func _on_interact_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.is_have_key_card == true:
			if not is_audio_played:
				$CardBeepSound.play()
				is_audio_played = true
			if $CollisionShape2D == null:
				return
			$CollisionShape2D.queue_free()
			$Sprite2D.modulate = Color(0.0, 0.0, 18.892, 0.392)
