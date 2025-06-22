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
@onready var pickups_parent_node: Node3D = %Pickups
var level_progress_display_manager: LevelProgressDisplayManager

func _ready() -> void:
	level_progress_display_manager = get_node_or_null("%LevelProgressDisplayManager")
	_connect_player_to_handlers()
	_connect_detectors_to_handlers()
	_connect_enemies_to_handlers()
	_connect_pickups_to_handlers()


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


func _handle_pickup_collide_with_player(color_from_pickup: Color) -> void:
	player.disguise_player(color_from_pickup)


func _connect_pickups_to_handlers() -> void:
	if not is_instance_valid(pickups_parent_node):
		return
	
	var pickup_nodes: Array[Node] = pickups_parent_node.get_children()
	for pickup_node: Node in pickup_nodes:
		if pickup_node is Disguise:
			pickup_node.collided_with_player.connect(_handle_pickup_collide_with_player)


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
		if enemy_node is Turret:
			enemy_node.fired_projectile.connect(_handle_enemy_fired_projectile)
		if enemy_node is Enemy:
			enemy_node.detected_player.connect(_handle_detector_player_detection)
			enemy_node.fired_projectile.connect(_handle_enemy_fired_projectile)
