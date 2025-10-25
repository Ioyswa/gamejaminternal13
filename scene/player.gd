extends CharacterBody2D


const SPEED = 500.0
var is_hiding := false
var can_hide := false

var is_have_key_card := false
var can_interact_with_keycard := false
var current_keycard: Area2D = null


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
	if Input.is_action_just_pressed("interact"):
		if can_hide:
			_toggle_hide()
		elif can_interact_with_keycard and current_keycard:
			_pickup_keycard(current_keycard)

func _pickup_keycard(card: Area2D):
	if not is_have_key_card:
		print("Player picked up keycard:", card.key_name)
		is_have_key_card = true
		card.collect()
		print("kartu dah diambil")
		# Bisa tambahkan efek suara, animasi, atau notifikasi UI di sini
	else:
		print("Player sudah punya keycard.")

func _toggle_hide():
	is_hiding = not is_hiding
	if is_hiding:
		print("🕶️ Player bersembunyi.")
		visible = false
	else:
		print("👀 Player keluar dari persembunyian.")
		visible = true

func _on_hide_spot_entered(area):
	can_hide = true
	current_hide_spot = area
	print("Player bisa bersembunyi di sini (tekan E).")

func _on_hide_spot_exited(area):
	can_hide = false
	current_hide_spot = null
	print("Keluar dari area persembunyian.")
