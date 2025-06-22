class_name LevelProgressDisplayManager extends Node

@onready var player: Player = %Player
@onready var pickups: Node3D = %Pickups
@onready var camera_3d: Camera3D = %Camera3D
@onready var goal: Detector = %Goal

var level_manager: LevelManager
var game_manager: GameManager
var last_completed_level_marker: LevelProgressMarker
var target_marker_for_movement: LevelProgressMarker

func _ready() -> void:
	level_manager = Globals.refs[Constants.LEVEL_MANAGER]
	game_manager = Globals.refs[Constants.GAME_MANAGER]
	_setup.call_deferred()


func _setup() -> void:
	player.set_movement_currently_allowed(false)
	var current_level: int = level_manager.get_current_level_index()
	var markers: Array[Node] = pickups.get_children()
	var markers_updated: int = 0
	print("determining level markers to update")
	for marker: Node in markers:
		if markers_updated == current_level:
			target_marker_for_movement = marker
			if last_completed_level_marker == null:
				last_completed_level_marker = marker
			print("markers updated matches current_level")
			break
		print("setting current level marker as complete")
		marker.set_level_complete()
		last_completed_level_marker = marker
		markers_updated += 2 # need to add extra here to account for progress level being in levels array
		print("markers_updated = ", markers_updated)
	
	player.global_position = last_completed_level_marker.global_position
	goal.global_position = target_marker_for_movement.global_position
	get_tree().create_timer(0.5).timeout.connect(_build_movement_tween)


func _build_movement_tween() -> void:
	var movement_tween = create_tween()
	movement_tween.tween_property(player, "global_position", target_marker_for_movement.global_position, 2.0)
	movement_tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
