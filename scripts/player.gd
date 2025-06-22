class_name Player extends CharacterBody3D

signal player_disguised(value: bool)
signal player_disguise_health_changed(new_disguise_health: float)

const PLAYER_LIFE_ORB: PackedScene = preload("res://scenes/game_objects/player_life_orb.tscn")
const ROTATION_SPEED: float = 1.2

@onready var player_mesh: MeshInstance3D = %PlayerMesh

@export var material_config: CellShaderConfig

var speed: int = 5
var drag_when_stopping: float = 0.03
var input_vector: Vector2 = Vector2.ZERO
var movement_direction: Vector2 = Vector2.ZERO
var movement_currently_allowed: bool = true
var bouncing_from_collision: bool = false
var bounceback_speed: float = 1.5
var bounceback_input_delay: float = 0.3
var currently_disguised: bool = false:
	set(value):
		currently_disguised = value
		player_disguised.emit(currently_disguised)
var disguise_damage_from_movement: float = 1.0
var current_disguise_health: float = 5.0
var max_disguise_health: float = 5.0
var valid_player_life_orb_spawn_offsets: Array[Vector3] = [
	Vector3.MODEL_TOP,
	Vector3.MODEL_BOTTOM,
	Vector3.MODEL_FRONT,
	Vector3.MODEL_REAR,
	Vector3.MODEL_LEFT,
	Vector3.MODEL_RIGHT
]
var player_life_orbs: Array[MeshInstance3D] = []
var life_orbs_visible: int = 0
var disguise_color: Color

func _ready() -> void:
	Globals.refs[Constants.PLAYER] = self
	Helpers.set_shader_instance_params(player_mesh, material_config)
	_spawn_player_life_orbs()
	_set_material_colors(material_config.primary_color, material_config.rim_color)


func _unhandled_input(_event: InputEvent) -> void:
	if not movement_currently_allowed:
		return
	
	input_vector = Input.get_vector(Constants.MOVE_LEFT, Constants.MOVE_RIGHT, Constants.MOVE_DOWN, Constants.MOVE_UP)


func _process(delta: float) -> void:
		rotate_y(delta * ROTATION_SPEED * input_vector.normalized().y)
		rotate_x(delta * ROTATION_SPEED * input_vector.normalized().x)
		rotate_z(delta * ROTATION_SPEED)


func _physics_process(delta: float) -> void:		
	var collided_during_movement: bool = move_and_slide()
	
	if bouncing_from_collision:
		velocity = velocity.move_toward(Vector3.ZERO, drag_when_stopping)
		_handle_disguise_degradation(delta)
		return
	
	if input_vector.is_zero_approx():
		movement_direction = movement_direction.move_toward(Vector2.ZERO, drag_when_stopping)
	else:
		movement_direction = input_vector.normalized()
		_handle_disguise_degradation(delta)
	
	if not collided_during_movement:
		velocity = Vector3(movement_direction.x * speed, movement_direction.y * speed, 0.0)
		return
	
	var collided_with_node: Node = get_last_slide_collision().get_collider()
	if collided_with_node is Disguise:
		collided_with_node.on_collided_with_player()
		
	velocity = Vector3(movement_direction.x * speed, movement_direction.y * speed, 0.0)
		
	var collision_normal: Vector3 = get_last_slide_collision().get_normal()
	_bounce_player(collision_normal)


func _handle_disguise_degradation(delta: float) -> void:
	if not currently_disguised:
		return
	
	current_disguise_health -= disguise_damage_from_movement * delta
	current_disguise_health = clampf(current_disguise_health, 0.0, max_disguise_health)
	var remapped_disguise_health: float = remap(current_disguise_health, 0.0, max_disguise_health, 0.0, 1.0)
	_set_material_colors(lerp(disguise_color, material_config.primary_color, 1.0 - remapped_disguise_health), lerp(disguise_color.lightened(0.5), material_config.rim_color, 1.0 - remapped_disguise_health))
	player_disguise_health_changed.emit(remapped_disguise_health * 100.0)
	if current_disguise_health == 0.0:
		currently_disguised = false
		current_disguise_health = max_disguise_health
		_set_material_colors(material_config.primary_color, material_config.rim_color)


func _bounce_player(normal_from_collision: Vector3) -> void:
	if bouncing_from_collision:
		return
	
	bouncing_from_collision = true
	get_tree().create_timer(bounceback_input_delay).timeout.connect(func() -> void: bouncing_from_collision = false)
	velocity = velocity.bounce(normal_from_collision.normalized())
	movement_direction = movement_direction.bounce(Vector2(normal_from_collision.x, normal_from_collision.y).normalized())


func disguise_player(color: Color) -> void:
	currently_disguised = true
	disguise_color = color
	player_disguise_health_changed.emit(remap(current_disguise_health, 0.0, max_disguise_health, 0.0, 100.0))
	_set_material_colors(color, color.lightened(0.5))


func remove_player_disguise() -> void:
	currently_disguised = false
	_set_material_colors(material_config.primary_color, material_config.rim_color)


func push_player_back(push_back_vector: Vector3 = Vector3.ZERO) -> void:
	if bouncing_from_collision:
		return
	
	bouncing_from_collision = true
	get_tree().create_timer(bounceback_input_delay).timeout.connect(func() -> void: bouncing_from_collision = false)
	
	if push_back_vector == Vector3.ZERO:
		velocity = -velocity
		movement_direction = -movement_direction
	else:
		print("Push back vector: ", push_back_vector)
		velocity = push_back_vector
		movement_direction = Vector2.ZERO


func _set_material_colors(color: Color, glow_color: Color) -> void:
	player_mesh.set_instance_shader_parameter("Color", color)
	player_mesh.set_instance_shader_parameter("glow_color", glow_color)
	for life_orb_node: Node3D in player_life_orbs:
		life_orb_node.set_instance_shader_parameter("Color", color)
		life_orb_node.set_instance_shader_parameter("glow_color", glow_color)


func _spawn_player_life_orbs() -> void:
	var counter: int = 0;
	while counter <= 5:
		var new_life_orb_node: Node3D = PLAYER_LIFE_ORB.instantiate()
		add_child(new_life_orb_node)
		new_life_orb_node.global_transform = global_transform.translated(valid_player_life_orb_spawn_offsets[counter] * 0.7)
		Helpers.set_shader_instance_params(new_life_orb_node, material_config)
		player_life_orbs.append(new_life_orb_node)
		life_orbs_visible += 1
		counter += 1


func hide_life_orb() -> void:
	for life_orb_node: Node3D in player_life_orbs:
		if life_orb_node.visible:
			life_orb_node.visible = false
			return


func set_visible_life_orbs(number_to_show: int) -> void:
	if life_orbs_visible == number_to_show:
		return
	
	if number_to_show > life_orbs_visible:
		var orbs_to_show: int = number_to_show - life_orbs_visible
		for life_orb_node: Node3D in player_life_orbs:
			if life_orb_node.visible:
				continue
			life_orb_node.visible = true
			orbs_to_show -= 1
			if orbs_to_show == 0:
				break
	else:
		var orbs_to_hide: int = life_orbs_visible - number_to_show
		for life_orb_node: Node3D in player_life_orbs:
			if not life_orb_node.visible:
				continue
			life_orb_node.visible = false
			orbs_to_hide -= 1
			if orbs_to_hide == 0:
				break


func set_movement_currently_allowed(value: bool) -> void:
	movement_currently_allowed = value
