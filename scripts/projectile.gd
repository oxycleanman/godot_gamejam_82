class_name Projectile extends AnimatableBody3D

signal projectile_hit_player()

@onready var cell_death_effect: GPUParticles3D = %CellDeathEffect
@onready var projectile_mesh: MeshInstance3D = %ProjectileMesh

@export var material_config: CellShaderConfig
@export var particle_material_config: CellShaderConfig

var speed: float = 3.0
var lifetime_in_seconds: float = 3.0
var push_back_force: float = 200.0
var player: Player
var velocity: Vector3
var exploding: bool = false


func _ready() -> void:
	player = Globals.refs[Constants.PLAYER]
	Helpers.set_shader_instance_params(projectile_mesh, material_config)
	Helpers.set_shader_instance_params(cell_death_effect, particle_material_config)
	velocity = global_position * speed
	get_tree().create_timer(lifetime_in_seconds).timeout.connect(_handle_lifetime_end)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or exploding:
		return
	
	
	var collision_info: KinematicCollision3D = move_and_collide(velocity)
	if not collision_info:
		velocity = global_position.direction_to(player.global_position) * speed * delta
		return
		
	var node_collided_with_rid: RID = collision_info.get_collider_rid()
	
	if node_collided_with_rid == player.get_rid():
		print("projectile hit player")
		projectile_hit_player.emit()
		exploding = true
		player.push_player_back(collision_info.get_travel() * push_back_force)
		_handle_impact_tween()
		return
		
	velocity = velocity.slide(collision_info.get_normal().normalized()) * speed


func _handle_impact_tween() -> void:
	var impact_tween: Tween = create_tween()
	impact_tween.tween_property(projectile_mesh, "scale", Vector3.ONE * 1.3, 0.15)
	impact_tween.set_trans(Tween.TRANS_EXPO)
	impact_tween.finished.connect(_handle_death_effect)


func _handle_death_effect() -> void:
	projectile_mesh.visible = false
	cell_death_effect.draw_pass_1.material.set_shader_parameter("Color", material_config.primary_color)
	cell_death_effect.emitting = true
	cell_death_effect.finished.connect(func() -> void: queue_free())


func _handle_lifetime_end() -> void:
	queue_free()
