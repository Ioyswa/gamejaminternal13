extends Area2D

@export var key_name: String = "main_keycard"
var is_collected: bool = false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
		
	if body.is_in_group("player"):
		$Label.visible = true
		body.can_interact_with_keycard = true
		body.current_keycard = self

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		$Label.visible = false
		body.can_interact_with_keycard = false
		body.current_keycard = null

func collect():
	if is_collected:
		return
	is_collected = true
	print("Keycard collected:", key_name)
	queue_free()
