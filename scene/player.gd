extends CharacterBody2D


const SPEED = 500.0
var is_hiding := false
var can_hide := false
var is_have_key_card := true

var default_layer: int
var default_mask: int

var current_hide_spot: Area2D = null

func _ready():
	default_layer = collision_layer
	default_mask = collision_mask

func _physics_process(delta: float) -> void:
	if not is_hiding:
		_handle_movement(delta)
	_handle_hide_input()

func _handle_movement(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * SPEED
	move_and_slide()

func _handle_hide_input():
	if can_hide and Input.is_action_just_pressed("interact"):
		is_hiding = not is_hiding
		if is_hiding:
			print("🕶️ Player bersembunyi.")
			visible = false   # sembunyikan sprite player
			collision_layer = 32
			collision_mask = 32
			#$CollisionShape2D.disabled = true  # opsional, kalau kamu mau musuh tidak nabrak player
		else:
			print("👀 Player keluar dari persembunyian.")
			visible = true
			collision_layer = default_layer
			collision_mask = default_mask
			
			#$CollisionShape2D.disabled = false


func _on_hide_spot_entered(area):
	can_hide = true
	current_hide_spot = area
	print("Player bisa bersembunyi di sini (tekan E).")

func _on_hide_spot_exited(area):
	can_hide = false
	current_hide_spot = null
	print("Keluar dari area persembunyian.")
