class_name LevelManager extends Node

const MAIN_MENU_BACKGROUND = preload("res://scenes/levels/main_menu_background.tscn")
const LEVEL_1_1 = preload("res://scenes/levels/level_1_1.tscn")
const LEVEL_1_2 = preload("res://scenes/levels/level_1_2.tscn")
const LEVEL_1_3 = preload("res://scenes/levels/level_1_3.tscn")

var current_level_node: Node
var current_level_index: int = -1
var game_levels: Array[PackedScene]


func _ready() -> void:
	Globals.refs[Constants.LEVEL_MANAGER] = self
	game_levels = [
		MAIN_MENU_BACKGROUND,
		LEVEL_1_2,
		LEVEL_1_3
	] 


func advance_level() -> Node:
	teardown_current_level()
	current_level_index += 1
	_load_level()
	return current_level_node


func reload_current_level() -> Node:
	teardown_current_level()
	_load_level()
	return current_level_node


func get_current_level() -> Node:
	return current_level_node


func teardown_current_level() -> void:
	if is_instance_valid(current_level_node):
		current_level_node.queue_free()


func _load_level() -> void:
	var new_level_node: Node = game_levels[current_level_index].instantiate()
	current_level_node = new_level_node
