class_name LevelProgressMarker extends Node3D

const ROTATE_SPEED: float = 3.0
const PLAYER_LIFE_ORB: PackedScene = preload("res://scenes/game_objects/player_life_orb.tscn")

@export var player_orb_material_config: CellShaderConfig

@onready var mesh_instance_3d: MeshInstance3D = %MeshInstance3D
@onready var level_complete_display: Node3D = %LevelCompleteDisplay
@onready var infection_fog_volume: FogVolume = %InfectionFogVolume

var level_complete: bool = false
var rotate_x_amount: float = 0.0
var rotate_y_amount: float = 0.0
var rotate_z_amount: float = 0.0

func _ready() -> void:
	if level_complete:
		mesh_instance_3d.visible = false
		infection_fog_volume.visible = true
		rotate_x_amount = randf()
		rotate_y_amount = randf()
		rotate_z_amount = randf()
		_spawn_visual_player_orbs()


func _process(delta: float) -> void:
	if not level_complete:
		return
	
	level_complete_display.rotate_x(ROTATE_SPEED * rotate_x_amount * delta)
	level_complete_display.rotate_y(ROTATE_SPEED * rotate_y_amount * delta)
	level_complete_display.rotate_z(ROTATE_SPEED * rotate_z_amount * delta)


func set_level_complete() -> void:
	level_complete = true
	mesh_instance_3d.visible = false
	infection_fog_volume.visible = true
	rotate_x_amount = randf()
	rotate_y_amount = randf()
	rotate_z_amount = randf()
	_spawn_visual_player_orbs()


func _spawn_visual_player_orbs() -> void:
	var spawned_orbs: int = 0
	while spawned_orbs < 5:
		var new_orb: Node = PLAYER_LIFE_ORB.instantiate()
		Helpers.set_shader_instance_params(new_orb, player_orb_material_config)
		level_complete_display.add_child(new_orb)
		new_orb.global_position = level_complete_display.global_position + Vector3(randf_range(-0.6, 0.6), randf_range(-0.6, 0.6), randf_range(-0.6, 0.6))
		new_orb.scale_object_local(Vector3.ONE * randf_range(0.6, 1.2))
		spawned_orbs += 1
