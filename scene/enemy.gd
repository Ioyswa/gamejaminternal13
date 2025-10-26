extends CharacterBody2D

# === NODES ===
@onready var vision_area = $VisionArea
@onready var vision_shape = $VisionArea/VisionShape
@onready var vision_visual = $VisionArea/VisionVisual
@onready var sight_ray = $RayCast2D
@onready var nav_agent = $NavigationAgent2D

# === PATROL SETTINGS ===
@export_group("Patrol Settings")
@export var point1: Node2D
@export var point2: Node2D
@export var point3: Node2D
@export var point4: Node2D
@export var run_speed := 150.0

# === VISION SETTINGS ===
@export_group("Vision Settings")
@export var vision_distance := 200.0
@export var vision_angle := 45.0 # derajat
@export var vision_color := Color(1, 0, 0, 0.2)

# === STATE VARIABLES ===
var patrol_points: Array[Vector2] = []
var current_patrol_index := 0
var is_patrolling := true
var is_chasing := false
var player_detected := false
var last_seen_position: Vector2 = Vector2.ZERO
var player: Node2D = null

# === MEMORY SETTINGS ===
var memory_time := 1.0     # Waktu "mengingat" player setelah hilang
var memory_timer := 0.0

# === TIMERS ===
@onready var reaction_timer := Timer.new()
@onready var repath_timer := Timer.new()

# -------------------------------------------------------------
func _ready():
	# --- Connect signals ---
	$CatchZone.connect("body_entered", Callable(self, "_on_catch_zone_entered"))
	vision_area.connect("body_entered", Callable(self, "_on_body_entered"))
	vision_area.connect("body_exited", Callable(self, "_on_body_exited"))

	# --- Setup cone vision ---
	_update_cone_shape()
	_update_vision_cone()

# --- Setup patrol points ---
	patrol_points = []

	if point1: patrol_points.append(point1.global_position)
	if point2: patrol_points.append(point2.global_position)
	if point3: patrol_points.append(point3.global_position)
	if point4: patrol_points.append(point4.global_position)

	if patrol_points.size() > 0:
		_update_target(patrol_points[current_patrol_index])

	# --- Setup timers ---
	reaction_timer.one_shot = true
	repath_timer.one_shot = false
	repath_timer.wait_time = 0.25  # Update path setiap 0.25 detik
	add_child(reaction_timer)
	add_child(repath_timer)
	repath_timer.connect("timeout", Callable(self, "_on_repath_timer_timeout"))

# -------------------------------------------------------------
func _physics_process(delta):
	velocity = Vector2.ZERO

	# --- Chase logic ---
	if is_chasing:
		if nav_agent.is_navigation_finished():
			if memory_timer > 0:
				memory_timer -= delta
			else:
				# Player hilang total → balik patroli
				is_chasing = false
				is_patrolling = true
				_update_target(patrol_points[current_patrol_index])
				vision_visual.color = vision_color
		else:
			_move_to_target(delta)
			vision_visual.color = Color(1, 0, 0, 0.3)

	# --- Patrol logic ---
	elif is_patrolling:
		_patrol(delta)
	
	else:
		check_player_visibility()
	
	move_and_slide()

# -------------------------------------------------------------
# ========== PATROL BEHAVIOR ==========
func _patrol(delta):
	if nav_agent.is_navigation_finished():
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		_update_target(patrol_points[current_patrol_index])
	_move_to_target(delta)

# -------------------------------------------------------------
# ========== DETECTION EVENTS ==========
func _on_body_entered(body: Node2D):
	if body.is_in_group("player") and not body.is_hiding:
		print(body.is_hiding)
		
		player_detected = true
		player = body
		vision_visual.color = Color(1, 0, 0, 0.4)

		# Delay kecil biar terlihat natural
		reaction_timer.start(0.1)
		await reaction_timer.timeout

		if not _check_wall_between():
			_start_chasing()

func check_player_visibility():
	if not player:
		return

	# Jika player terlihat lagi setelah keluar sembunyi
	if vision_area.overlaps_body(player) and not player.is_hiding and not _check_wall_between():
		print("👁️ Player terlihat lagi setelah keluar sembunyi!")
		_start_chasing()

func _on_body_exited(body: Node2D):
	if body.is_in_group("player"):
		player_detected = false
		memory_timer = memory_time  # Masih "ingat" posisi player sebentar
		player = null
		vision_visual.color = vision_color

# -------------------------------------------------------------
# ========== CHASE SYSTEM ==========
func _start_chasing():
	if not player:
		return
	last_seen_position = player.global_position
	is_chasing = true
	is_patrolling = false
	_update_target(last_seen_position)
	repath_timer.start()  # mulai update path secara berkala
	vision_visual.color = Color(1, 0, 0, 0.5)

func _on_repath_timer_timeout():
	if is_chasing and player and not _check_wall_between():
		last_seen_position = player.global_position
		_update_target(last_seen_position)

# -------------------------------------------------------------
# ========== NAVIGATION AGENT ==========
func _update_target(target_pos: Vector2):
	nav_agent.target_position = target_pos

func _move_to_target(delta):
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return

	var next_point = nav_agent.get_next_path_position()
	var dir = (next_point - global_position)
	if dir.length() > 1:
		dir = dir.normalized()
		velocity = dir * run_speed
		var target_angle = dir.angle()
		rotation = lerp_angle(rotation, target_angle, delta * 8.0)
	else:
		velocity = Vector2.ZERO

# -------------------------------------------------------------
# ========== CONE & DETECTION ==========
func _check_wall_between() -> bool:
	if not player:
		return false

	var direction = player.global_position - global_position
	if direction.length() > vision_distance:
		return true # terlalu jauh, treat as blocked

	sight_ray.target_position = to_local(player.global_position)
	sight_ray.force_raycast_update()
	return sight_ray.is_colliding()

func _update_cone_shape():
	var half_angle = deg_to_rad(vision_angle / 2)
	var points = [
		Vector2.ZERO,
		Vector2(vision_distance * cos(-half_angle), vision_distance * sin(-half_angle)),
		Vector2(vision_distance * cos(half_angle), vision_distance * sin(half_angle))
	]
	vision_shape.polygon = points
	vision_visual.polygon = points
	vision_visual.color = vision_color

func _update_vision_cone():
	var half_angle = deg_to_rad(vision_angle / 2)
	var points = [
		Vector2.ZERO,
		Vector2(vision_distance * cos(-half_angle), vision_distance * sin(-half_angle)),
		Vector2(vision_distance * cos(half_angle), vision_distance * sin(half_angle))
	]
	$VisionArea/VisionShape.polygon = points

func _on_catch_zone_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Player tertangkap!")
		body._on_caught_by_enemy()
