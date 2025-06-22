class_name Detector extends Area3D

signal detected_player()
signal player_reached_goal()
signal player_hit_hazard()

var mesh_instance_3d: MeshInstance3D

@export_enum("Alert", "Collectable", "Goal", "Hazard") var detector_type: String
@export var material_config: CellShaderConfig
@export var goal_reached_signal_delay: float = 0.0
@export var show_goal_particle_effect: bool = true

@onready var goal_particle_effect: GPUParticles3D = %GoalParticleEffect


func _ready() -> void:
	if not detector_type == "Goal" or show_goal_particle_effect == false:
		goal_particle_effect.visible = false
	
	mesh_instance_3d = get_node_or_null("%MeshInstance3D")
	if mesh_instance_3d != null:
		Helpers.set_shader_instance_params(mesh_instance_3d, material_config)


func _on_body_entered(body: Node3D) -> void:
	match detector_type:
		"Alert":
			_handle_alert_detection(body)
		"Collectable":
			_handle_collectible_detection(body)
		"Goal":
			_handle_goal_detection(body)
		"Hazard":
			_handle_hazard_detection(body)


func _handle_alert_detection(body: Node3D) -> void:
	if body is Player and not body.currently_disguised:
		detected_player.emit()


func _handle_collectible_detection(_body: Node3D) -> void:
	print("Picked up collectable")


func _handle_goal_detection(body: Node3D) -> void:
	if body is Player:
		if goal_reached_signal_delay < 0.1:
			player_reached_goal.emit()
			return
		
		get_tree().create_timer(goal_reached_signal_delay).timeout.connect(func() -> void: player_reached_goal.emit())

func _handle_hazard_detection(body: Node3D) -> void:
	if body is Player:
		player_hit_hazard.emit()
		body.push_player_back()
		queue_free()
