# Acts as a level-wide signal relay. Allows manager classes to get events from each level without 
# needing to know how each level is constructed

class_name LevelManager extends Node3D

signal level_player_disguised(value: bool)
signal level_disguise_health_changed(new_disguise_health: float)
signal level_player_detected()
signal level_goal_reached()

@onready var player: Player = %Player
@onready var detector_parent_node: Node3D = %Detectors


func _ready() -> void:
	_connect_player_to_handlers()
	_connect_detectors_to_handlers()

func _handle_player_disguised_signal(value: bool) -> void:
	level_player_disguised.emit(value)


func _handle_player_diguise_health_changed(new_disguise_health: float) -> void:
	level_disguise_health_changed.emit(new_disguise_health)


func _handle_detector_player_detection() -> void:
	level_player_detected.emit()


func _handle_detector_goal_reached() -> void:
	level_goal_reached.emit()


func _connect_player_to_handlers() -> void:
	player.player_disguised.connect(_handle_player_disguised_signal)
	player.player_disguise_health_changed.connect(_handle_player_diguise_health_changed)


func _connect_detectors_to_handlers() -> void:
	var detectors: Array[Node] = detector_parent_node.get_children()
	for detector_node: Node in detectors:
		if detector_node is not Detector:
			continue
		
		var detector: Detector = detector_node as Detector
		detector.detected_player.connect(_handle_detector_player_detection)
		detector.player_reached_goal.connect(_handle_detector_goal_reached)
