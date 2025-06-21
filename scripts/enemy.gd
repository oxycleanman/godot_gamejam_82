class_name Enemy extends AnimatableBody3D

signal detected_player()
signal fired_projectile(projectile: Projectile)

const PROJECTILE: PackedScene = preload("res://scenes/game_objects/projectile.tscn")

@onready var visible_scan_area: MeshInstance3D = %VisibleScanArea
@onready var visual_detector: Area3D = %VisualDetector
@onready var mesh: MeshInstance3D = %Body
@onready var projectile_spawn_point: Marker3D = %ProjectileSpawnPoint

@export var move_distance: float = 10.0
@export var move_speed: float = 2.0
@export var material_config: CellShaderConfig

var distance_moved: float = 0.0
var velocity: Vector3
var target_rotated_basis: Basis
var rotation_tween: Tween
var scanning: bool = false
var tracking_player: bool = false
var currently_colliding: bool = false
var projectile: Projectile
var player: Player

func _ready() -> void:
	Helpers.set_shader_instance_params(mesh, material_config)
	visible_scan_area.visible = false

func _physics_process(delta: float) -> void:
	if scanning or currently_colliding:
		return
	
	var collision_info: KinematicCollision3D = move_and_collide(velocity)
	if collision_info:
		print("enemy collided with something")
		currently_colliding = true
		var collided_with_node: Node = collision_info.get_collider()
		if collided_with_node is Player:
			print("enemy collided with player")
			queue_free()
			return
		tracking_player = false
		distance_moved = 0.0
		_handle_rotation()
		return
		
	if tracking_player:
		_track_player_and_shoot(delta)
		return
	
	velocity = -global_transform.basis.x * move_speed * delta
	distance_moved += move_speed * delta
	
	if distance_moved >= move_distance:
		_scan_and_rotate()
		return


func _track_player_and_shoot(delta: float) -> void:
	print("trying to track player")
	velocity = global_position.direction_to(player.global_position) * move_speed * delta
	var bodies: Array[Node3D] = visual_detector.get_overlapping_bodies()
	for body: Node3D in bodies:
		if body is Player:
			_try_to_fire_projectile()
			return
	
	tracking_player = false


func _scan_and_rotate() -> void:
	print("scanning and rotating")
	scanning = true
	visible_scan_area.visible = true
	distance_moved = 0.0
	_check_if_player_in_scan_range()
	get_tree().create_timer(3.0).timeout.connect(_handle_rotation)


func _check_if_player_in_scan_range() -> void:
	var bodies: Array[Node3D] = visual_detector.get_overlapping_bodies()
	for body: Node3D in bodies:
		_on_visual_detector_body_entered(body)


func _handle_rotation() -> void:
	print("trying to rotate")
	if tracking_player:
		return
	
	target_rotated_basis = global_basis.rotated(Vector3.UP, deg_to_rad(180.0))
	rotation_tween = create_tween()
	rotation_tween.tween_method(_rotate_basis, 0.0, 1.0, 1.0)
	rotation_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	rotation_tween.finished.connect(_finish_scan_and_rotation)


func _rotate_basis(weight: float) -> void:
	global_basis = global_basis.slerp(target_rotated_basis, weight)


func _finish_scan_and_rotation() -> void:
	print("finishing scan and rotation")
	scanning = false
	tracking_player = false
	visible_scan_area.visible = false
	currently_colliding = false
	velocity = -global_transform.basis.x * move_speed * get_physics_process_delta_time()


func _on_visual_detector_body_entered(body: Node3D) -> void:
	print("checking for overlapping bodies in scan range")
	if not scanning:
		return
	
	if body is Player:
		if not body.currently_disguised:
			detected_player.emit()
			player = body
			tracking_player = true
			scanning = false
			_try_to_fire_projectile()


func _try_to_fire_projectile() -> void:
	print("trying to shoot player")
	if is_instance_valid(projectile):
		return
	
	var projectile_node: Node3D = PROJECTILE.instantiate()
	projectile = projectile_node as Projectile
	get_tree().current_scene.get_node("%GameWorld").add_child(projectile_node)
	projectile_node.global_position = projectile_spawn_point.global_position
	fired_projectile.emit(projectile)
