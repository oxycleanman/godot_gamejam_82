class_name Helpers extends RefCounted

static func set_shader_instance_params(mesh: GeometryInstance3D, config: CellShaderConfig) -> void:
	mesh.set_instance_shader_parameter("Color", config.primary_color)
	mesh.set_instance_shader_parameter("glow_color", config.rim_color)
	mesh.set_instance_shader_parameter("dist", config.core_transparency)
	mesh.set_instance_shader_parameter("speed", config.effect_speed)
	mesh.set_instance_shader_parameter("glow_intensity", config.rim_glow_intensity)
	mesh.set_instance_shader_parameter("glow_amount", config.rim_glow_amount)
	mesh.set_instance_shader_parameter("posMult", config.mesh_displacement_amount)
