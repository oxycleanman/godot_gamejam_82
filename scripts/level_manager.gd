class_name LevelManager extends Node

# TODO: make better level loading system
const TEST_LEVEL: PackedScene = preload("res://scenes/levels/test_level.tscn")
const LEVEL_TEMPLATE: PackedScene = preload("res://scenes/levels/level_template.tscn")

var current_level_node: Node
var current_level_index: int = -1
var game_levels: Array[PackedScene]


func _ready() -> void:
	Globals.refs[Constants.LEVEL_MANAGER] = self
	game_levels = [
		TEST_LEVEL,
		LEVEL_TEMPLATE
	] 


func advance_level() -> Node:
	teardown_current_level()
	current_level_index += 1
	_load_level()
	return current_level_node


func reload_current_level() -> Node:
	current_level_node.queue_free()
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
