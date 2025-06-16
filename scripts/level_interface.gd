class_name LevelInterface extends Node3D

signal level_player_disguised(value: bool)
signal level_disguise_health_changed(new_disguise_health: float)
signal level_player_detected()
signal level_goal_reached()
signal level_fired_projectile(projectile: Projectile)
signal level_player_hit_hazard()

@onready var player: Player = %Player
@onready var detector_parent_node: Node3D = %Detectors
@onready var enemy_parent_node: Node3D = %Enemies

func _ready() -> void:
	_connect_player_to_handlers()
	_connect_detectors_to_handlers()
	_connect_enemies_to_handlers()


func _handle_player_disguised_signal(value: bool) -> void:
	level_player_disguised.emit(value)


func _handle_player_diguise_health_changed(new_disguise_health: float) -> void:
	level_disguise_health_changed.emit(new_disguise_health)


func _handle_detector_player_detection() -> void:
	level_player_detected.emit()


func _handle_detector_goal_reached() -> void:
	level_goal_reached.emit()


func _handle_player_hit_hazard() -> void:
	level_player_hit_hazard.emit()


func _handle_enemy_fired_projectile(projectile: Projectile) -> void:
	level_fired_projectile.emit(projectile)


func _connect_player_to_handlers() -> void:
	player.player_disguised.connect(_handle_player_disguised_signal)
	player.player_disguise_health_changed.connect(_handle_player_diguise_health_changed)


func _connect_detectors_to_handlers() -> void:
	if not is_instance_valid(detector_parent_node):
		return
	
	var detectors: Array[Node] = detector_parent_node.get_children()
	for detector_node: Node in detectors:
		if detector_node is not Detector:
			continue
		
		var detector: Detector = detector_node as Detector
		detector.detected_player.connect(_handle_detector_player_detection)
		detector.player_reached_goal.connect(_handle_detector_goal_reached)
		detector.player_hit_hazard.connect(_handle_player_hit_hazard)


func _connect_enemies_to_handlers() -> void:
	if not is_instance_valid(enemy_parent_node):
		return
	
	var enemies: Array[Node] = enemy_parent_node.get_children()
	for enemy_node: Node in enemies:
		if enemy_node is not Turret:
			continue
		
		var turret: Turret = enemy_node as Turret
		turret.fired_projectile.connect(_handle_enemy_fired_projectile)
