class_name GameManager extends Node3D

@onready var game_world: Node3D = %GameWorld
var ui_manager: UIManager
var camera_manager: CameraManager
var level_manager: LevelManager
var player_lives: int = 3


func _ready() -> void:
	Globals.refs[Constants.GAME_MANAGER] = self
	ui_manager = Globals.refs[Constants.UI_MANAGER]
	camera_manager = Globals.refs[Constants.CAMERA_MANAGER]
	level_manager = Globals.refs[Constants.LEVEL_MANAGER]
	_start_game()


func _start_game() -> void:
	ui_manager.set_player_lives(player_lives)
	_advance_level()


func _advance_level() -> void:
	var new_level: Node = level_manager.advance_level()
	game_world.add_child(new_level)
	_connect_level_interface_signals()
	camera_manager.on_level_loaded()
	ui_manager.on_new_level_loaded()


func _connect_level_interface_signals() -> void:
	var level_interface: LevelInterface = level_manager.get_current_level() as LevelInterface
	level_interface.level_disguise_health_changed.connect(ui_manager.on_player_disguise_health_changed)
	level_interface.level_player_disguised.connect(ui_manager.on_player_disguised)
	level_interface.level_player_detected.connect(ui_manager.on_player_detected)
	level_interface.level_player_hit_hazard.connect(_handle_player_hit)
	level_interface.level_goal_reached.connect(_handle_goal_reached)
	level_interface.level_fired_projectile.connect(_handle_projectiles)


func _handle_goal_reached() -> void:
	level_manager.teardown_current_level()
	_cleanup_game_world()
	ui_manager.on_goal_reached()
	await get_tree().create_timer(1.0).timeout
	_advance_level()


func _reset_current_level() -> void:
	var level_node: Node = level_manager.reload_current_level()
	_cleanup_game_world()
	ui_manager.on_goal_reached()
	await get_tree().create_timer(1.0).timeout
	_connect_level_interface_signals()
	ui_manager.set_player_lives(3)
	game_world.add_child(level_node)
	camera_manager.on_level_loaded()
	ui_manager.on_new_level_loaded()


func _cleanup_game_world() -> void:
	var child_nodes: Array[Node] = game_world.get_children()
	for child_node: Node in child_nodes:
		child_node.queue_free()


func _handle_projectiles(projectile: Projectile) -> void:
	projectile.projectile_hit_player.connect(_handle_player_hit)


func _handle_player_hit() -> void:
	player_lives -= 1
	ui_manager.set_player_lives(player_lives)
	
	if player_lives <= 0:
		_reset_current_level()
		player_lives = 3
