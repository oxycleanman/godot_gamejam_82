class_name Disguise extends Node3D

signal collided_with_player(color_of_disguise: Color)

@onready var death_particle_effect: GPUParticles3D = %DeathParticleEffect
@onready var cell_mesh: MeshInstance3D = %CellMesh
@onready var death_sound_player: AudioStreamPlayer3D = %DeathSoundPlayer
@onready var circular_marker: MeshInstance3D = %CircularMarker

@export var material_config: CellShaderConfig
@export var particle_material_config: CellShaderConfig

var handling_collision_with_player: bool = false


func _ready() -> void:
	Helpers.set_shader_instance_params(cell_mesh, material_config)
	Helpers.set_shader_instance_params(death_particle_effect, particle_material_config)


func _handle_impact_tween() -> void:
	var impact_tween: Tween = create_tween()
	impact_tween.tween_property(cell_mesh, "scale", Vector3.ONE * 1.3, 0.15)
	impact_tween.set_trans(Tween.TRANS_EXPO)
	impact_tween.finished.connect(_handle_death_effect)


func _handle_death_effect() -> void:
	print("_handle_death_effect called")
	cell_mesh.visible = false
	circular_marker.visible = false
	death_sound_player.play()
	death_particle_effect.emitting = true
	death_particle_effect.finished.connect(func() -> void: queue_free())


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		if handling_collision_with_player:
			return
		
		handling_collision_with_player = true
		collided_with_player.emit(material_config.primary_color)
		_handle_impact_tween()
