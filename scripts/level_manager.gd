class_name LevelManager extends Node

signal reached_end_of_levels()

const MAIN_MENU_BACKGROUND = preload("res://scenes/levels/main_menu_background.tscn")
const PROGRESS_DISPLAY_LEVEL = preload("res://scenes/levels/progress_display_level.tscn")
const LEVEL_1_1 = preload("res://scenes/levels/level_1_1.tscn")
const LEVEL_1_2 = preload("res://scenes/levels/level_1_2.tscn")
const LEVEL_1_3 = preload("res://scenes/levels/level_1_3.tscn")
const LEVEL_1_4 = preload("res://scenes/levels/level_1_4.tscn")
const LEVEL_1_5 = preload("res://scenes/levels/level_1_5.tscn")

var current_level_node: Node
var current_level_index: int = -1
var game_levels: Array[PackedScene]


func _ready() -> void:
	Globals.refs[Constants.LEVEL_MANAGER] = self
	# There's definitely a better way to do this, right?
	# ......... Right?
	game_levels = [
		MAIN_MENU_BACKGROUND,
		LEVEL_1_1,
		PROGRESS_DISPLAY_LEVEL,
		LEVEL_1_2,
		PROGRESS_DISPLAY_LEVEL,
		LEVEL_1_3,
		PROGRESS_DISPLAY_LEVEL,
		LEVEL_1_4,
		PROGRESS_DISPLAY_LEVEL,
		LEVEL_1_5,
		PROGRESS_DISPLAY_LEVEL
	]


func advance_level() -> Node:
	teardown_current_level()
	
	current_level_index += 1
	if current_level_index == game_levels.size() - 1: #last element is progress level
		print("level manager end of levels")
		reached_end_of_levels.emit()
		current_level_node = game_levels.pop_back().instantiate()
		return current_level_node
		
	_load_level()
	return current_level_node


func reload_current_level() -> Node:
	teardown_current_level()
	_load_level()
	return current_level_node


func get_current_level() -> Node:
	return current_level_node


func get_current_level_index() -> int:
	return current_level_index


func teardown_current_level() -> void:
	if is_instance_valid(current_level_node):
		current_level_node.queue_free()


func _load_level() -> void:
	print("loading level at index: ", current_level_index)
	var new_level_node: Node = game_levels[current_level_index].instantiate()
	current_level_node = new_level_node
