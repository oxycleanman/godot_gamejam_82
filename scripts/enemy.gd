class_name Enemy extends AnimatableBody3D

signal detected_player()

@onready var visible_scan_area: MeshInstance3D = %VisibleScanArea
@onready var visual_detector: Area3D = %VisualDetector
@onready var mesh: MeshInstance3D = %Body

@export var move_distance: float = 10.0
@export var move_speed: float = 2.0
@export var material_config: CellShaderConfig

var distance_moved: float = 0.0
var velocity: Vector3
var target_rotated_basis: Basis
var rotation_tween: Tween
var scanning: bool = false

func _ready() -> void:
	Helpers.set_shader_instance_params(mesh, material_config)
	visible_scan_area.visible = false

func _physics_process(delta: float) -> void:
	if scanning:
		return
	
	velocity = -global_transform.basis.x * move_speed * delta
	distance_moved += move_speed * delta
	
	if distance_moved >= move_distance:
		_scan_and_rotate()
		return
	
	move_and_collide(velocity)


func _scan_and_rotate() -> void:
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
	target_rotated_basis = global_basis.rotated(Vector3.UP, TAU/2)
	rotation_tween = create_tween()
	rotation_tween.tween_method(_rotate_basis, 0.0, 1.0, 1.0)
	rotation_tween.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN_OUT)
	rotation_tween.finished.connect(_finish_scan_and_rotation)


func _rotate_basis(weight: float) -> void:
	global_basis = global_basis.slerp(target_rotated_basis, weight)


func _finish_scan_and_rotation() -> void:
	scanning = false
	visible_scan_area.visible = false


func _on_visual_detector_body_entered(body: Node3D) -> void:
	if not scanning:
		return
	
	if body is Player:
		if not body.currently_disguised:
			detected_player.emit()
