class_name CameraManager extends Camera3D

var player: Player
var camera_move_speed: float = 10.0


func _ready() -> void:
	Globals.refs[Constants.CAMERA_MANAGER] = self
	_setup.call_deferred()


func _setup() -> void:
	update_player_reference()


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	
	var new_position: Vector3 = global_position.move_toward(player.global_position, camera_move_speed * delta)
	if new_position.is_zero_approx():
		return
	
	global_position = Vector3(new_position.x, new_position.y, 10.0)


func update_player_reference() -> void:
	player = Globals.refs[Constants.PLAYER]
