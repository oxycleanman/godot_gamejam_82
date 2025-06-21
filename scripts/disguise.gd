class_name Disguise extends Node3D

@onready var death_particle_effect: GPUParticles3D = %DeathParticleEffect
@onready var cell_mesh: MeshInstance3D = %CellMesh

@export var material_config: CellShaderConfig
@export var particle_material_config: CellShaderConfig

var player: Player


func _ready() -> void:
	Helpers.set_shader_instance_params(cell_mesh, material_config)
	Helpers.set_shader_instance_params(death_particle_effect, particle_material_config)
	_setup.call_deferred()


func _setup() -> void:
	player = Globals.refs.get(Constants.PLAYER)


func on_collided_with_player() -> void:
	player.disguise_player(material_config.primary_color)
	_handle_impact_tween()


func _handle_impact_tween() -> void:
	var impact_tween: Tween = create_tween()
	impact_tween.tween_property(cell_mesh, "scale", Vector3.ONE * 1.3, 0.15)
	impact_tween.set_trans(Tween.TRANS_EXPO)
	impact_tween.finished.connect(_handle_death_effect)


func _handle_death_effect() -> void:
	cell_mesh.visible = false
	death_particle_effect.emitting = true
	death_particle_effect.finished.connect(func() -> void: queue_free())
