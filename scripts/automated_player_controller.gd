extends Node

var move_positions: Array[Marker3D] = []
var player: Player
var movement_duration: float = 1.7
var current_target_move_position: Marker3D
var movement_tween: Tween
var is_moving: bool = false
var move_position_index: int = 0

func _ready() -> void:
	_setup.call_deferred()


func _setup() -> void:
	player = Globals.refs[Constants.PLAYER]
	player.set_movement_currently_allowed(false)
	var child_nodes: Array[Node] = get_children()
	for child_node: Node in child_nodes:
		if not child_node is Marker3D:
			continue
		move_positions.append(child_node)
	current_target_move_position = move_positions.front()


func _physics_process(delta: float) -> void:
	if is_moving or move_positions.is_empty():
		if is_instance_valid(player) and player.currently_disguised:
			player._handle_disguise_degradation(delta)
		return
	
	is_moving = true
	_build_movement_tween()


func _build_movement_tween() -> void:
	movement_tween = create_tween()
	movement_tween.tween_property(player, "global_position", current_target_move_position.global_position, movement_duration)
	movement_tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	movement_tween.finished.connect(_handle_movement_tween_complete)


func _handle_movement_tween_complete() -> void:
	if move_position_index + 1 == move_positions.size():
		#move_position_index = 0
		return
	else:
		move_position_index += 1
		
	current_target_move_position = move_positions.get(move_position_index)
	_build_movement_tween()


func _move_to_position(weight: float) -> void:
	player.global_position = player.global_position.lerp(current_target_move_position.global_position, weight)
