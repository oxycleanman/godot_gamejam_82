class_name CameraManager extends Camera3D

signal fade_complete()

@onready var scene_fade_mesh: MeshInstance3D = %SceneFadeMesh

var player: Player
var camera_move_speed: float = 30.0
var camera_z_offset: float = 20.0


func _ready() -> void:
	Globals.refs[Constants.CAMERA_MANAGER] = self
	_setup.call_deferred()


func _setup() -> void:
	_update_player_reference()


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	
	var new_position: Vector3 = global_position.move_toward(player.global_position, camera_move_speed * delta)
	if new_position.is_zero_approx():
		return
	
	global_position = Vector3(new_position.x, new_position.y, camera_z_offset)


func _update_player_reference() -> void:
	player = Globals.refs[Constants.PLAYER]
	

func on_level_loaded() -> void:
	_update_player_reference()
	global_position = Vector3(player.global_position.x, player.global_position.y, camera_z_offset)
	fade_from_black(2.0)


func fade_to_black(fade_duration: float = 1.0) -> void:
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(scene_fade_mesh, "transparency", 0.0, fade_duration)
	fade_tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	fade_tween.finished.connect(func() -> void: fade_complete.emit())


func fade_from_black(fade_duration: float = 1.0) -> void:
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(scene_fade_mesh, "transparency", 1.0, fade_duration)
	fade_tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	fade_tween.finished.connect(func() -> void: fade_complete.emit())
