class_name GameManager extends Node3D

# TODO: make better level loading system
const TEST_LEVEL: PackedScene = preload("res://scenes/levels/test_level.tscn")
const LEVEL_TEMPLATE: PackedScene = preload("res://scenes/levels/level_template.tscn")

@onready var game_world: Node3D = %GameWorld
var ui_manager: UIManager
var current_level_node: Node
var current_level_index: int = 0
var game_levels: Array[PackedScene]

func _ready() -> void:
	Globals.refs[Constants.GAME_MANAGER] = self
	ui_manager = Globals.refs.get(Constants.UI_MANAGER)
	game_levels = [
		TEST_LEVEL,
		LEVEL_TEMPLATE
	] 
	_start_game()


func _start_game() -> void:
	_advance_level()


func _advance_level() -> void:
	# This function will need to determine what level to load, then load it
	# After loading the level, it will need to connect the detectors and player from the new level
	# to the appropriate classes so events are handled correctly for the new level
	var new_level: Node = game_levels[current_level_index].instantiate()
	var new_level_manager: LevelManager = new_level as LevelManager
	new_level_manager.level_disguise_health_changed.connect(ui_manager.on_player_disguise_health_changed)
	new_level_manager.level_player_disguised.connect(ui_manager.on_player_disguised)
	new_level_manager.level_player_detected.connect(ui_manager.on_player_detected)
	new_level_manager.level_goal_reached.connect(_handle_goal_reached)
	
	game_world.add_child(new_level)
	current_level_node = new_level
	current_level_index += 1
	ui_manager.on_new_level_loaded()

func _handle_goal_reached() -> void:
	game_world.remove_child.call_deferred(current_level_node)
	current_level_node.queue_free()
	ui_manager.on_goal_reached()
	await get_tree().create_timer(1.0).timeout
	_advance_level()
