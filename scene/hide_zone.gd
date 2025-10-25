extends Area2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("masuk hidespot")
		body._on_hide_spot_entered(self)

func _on_body_exited(body):
	if body.is_in_group("player"):
		body._on_hide_spot_exited(self)
