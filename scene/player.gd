extends CharacterBody2D


const SPEED = 500.0

@onready var footstep_player = $FootstepPlayer

var is_hiding := false
var can_hide := false

var is_have_key_card := false
var can_interact_with_keycard := false
var current_keycard: Area2D = null


var default_layer: int
var default_mask: int

var current_hide_spot: Area2D = null


var footstep_interval := 0.3  # waktu antar langkah (detik)
var footstep_timer := 0.0

func _ready():
	Data.previous_level = 2
	default_layer = collision_layer
	default_mask = collision_mask

func _physics_process(delta: float) -> void:
	if not is_hiding:
		_handle_movement(delta)
	_handle_hide_input()

func _handle_movement(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * SPEED

	if input_dir != Vector2.ZERO:
		footstep_timer -= delta
		if footstep_timer <= 0.0:
			_play_footstep()
			footstep_timer = footstep_interval
	else:
		footstep_timer = 0.0
		_stop_footstep()

	move_and_slide()

func _stop_footstep():
	if footstep_player.playing:
		footstep_player.stop()

func _play_footstep():
	if footstep_player.playing:
		return # Jangan tumpuk suara
	footstep_player.pitch_scale = randf_range(0.9, 1.1) # Variasi biar natural
	footstep_player.play()

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

func _on_caught_by_enemy():
	print("GAME OVER: Player caught!")
	set_process(false) # hentikan input
	set_physics_process(false) # hentikan gerak
	_lose_sequence()
	
	
func _lose_sequence():
	# Efek suara tertangkap
	var caught_sfx = AudioStreamPlayer2D.new()
	caught_sfx.stream = preload("res://assets/Audio/caught.mp3")
	caught_sfx.volume_db = -3
	get_tree().root.add_child(caught_sfx)
	caught_sfx.play()

	# Setelah fade selesai → ganti ke scene Game Over
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://UI/game_over.tscn")
