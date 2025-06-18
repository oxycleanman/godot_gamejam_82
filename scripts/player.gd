class_name Player extends CharacterBody3D

signal player_disguised(value: bool)
signal player_disguise_health_changed(new_disguise_health: float)

const PLAYER_LIFE_ORB = preload("res://scenes/game_objects/player_life_orb.tscn")

@export var starting_base_color: Color
@export var starting_glow_color: Color
@export var player_material: ShaderMaterial
@export var player_life_orb_material: ShaderMaterial

var speed: int = 5
var drag_when_stopping: float = 0.03
var input_vector: Vector2 = Vector2.ZERO
var movement_direction: Vector2 = Vector2.ZERO
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
var player_life_orbs: Array[MeshInstance3D] = []

func _ready() -> void:
	Globals.refs[Constants.PLAYER] = self
	_spawn_player_life_orbs()
	_set_material_colors(starting_base_color, starting_glow_color)


func _unhandled_input(_event: InputEvent) -> void:
	input_vector = Input.get_vector(Constants.MOVE_LEFT, Constants.MOVE_RIGHT, Constants.MOVE_DOWN, Constants.MOVE_UP)


func _physics_process(delta: float) -> void:		
	var collided_during_movement: bool = move_and_slide()
	
	if bouncing_from_collision:
		velocity = velocity.move_toward(Vector3.ZERO, drag_when_stopping)
		_handle_disguise_degredation(delta)
		return
	
	if input_vector.is_zero_approx():
		movement_direction = movement_direction.move_toward(Vector2.ZERO, drag_when_stopping)
		#player_material.set_shader_parameter("posMult", .05)
	else:
		#player_material.set_shader_parameter("posMult", 1.0)
		movement_direction = input_vector
		rotate_object_local(Vector3.UP, delta * movement_direction.x * speed)
		rotate_object_local(Vector3.LEFT, delta * movement_direction.y * speed)
		_handle_disguise_degredation(delta)
	
	if not collided_during_movement:
		velocity = Vector3(movement_direction.x * speed, movement_direction.y * speed, 0.0)
		return
	
	var collision_normal: Vector3 = get_last_slide_collision().get_normal()
	_bounce_player(collision_normal)


func _handle_disguise_degredation(delta: float) -> void:
	if not currently_disguised:
		return
	
	current_disguise_health -= disguise_damage_from_movement * delta
	current_disguise_health = clampf(current_disguise_health, 0.0, max_disguise_health)
	# remapping disguise health to 0-100 scale so it displays in progress bar correctly
	player_disguise_health_changed.emit(remap(current_disguise_health, 0.0, max_disguise_health, 0.0, 100.0))
	if current_disguise_health == 0.0:
		currently_disguised = false
		current_disguise_health = max_disguise_health
		_set_material_colors(starting_base_color, starting_glow_color)


func _bounce_player(normal_from_collision: Vector3) -> void:
	if bouncing_from_collision:
		return
	
	bouncing_from_collision = true
	get_tree().create_timer(bounceback_input_delay).timeout.connect(func() -> void: bouncing_from_collision = false)
	velocity = velocity.bounce(normal_from_collision.normalized()) * bounceback_speed
	movement_direction = movement_direction.bounce(Vector2(normal_from_collision.x, normal_from_collision.y).normalized())


func disguise_player(color: Color) -> void:
	currently_disguised = true
	player_disguise_health_changed.emit(remap(current_disguise_health, 0.0, max_disguise_health, 0.0, 100.0))
	_set_material_colors(color, color.lightened(0.5))


func remove_player_disguise() -> void:
	currently_disguised = false
	_set_material_colors(starting_base_color, starting_glow_color)


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
	player_material.set_shader_parameter("Color", color)
	player_material.set_shader_parameter("glow_color", glow_color)
	player_life_orb_material.set_shader_parameter("Color", color)
	player_life_orb_material.set_shader_parameter("glow_color", glow_color)


func _spawn_player_life_orbs() -> void:
	var counter: int = 0;
	while counter <= 5:
		var position_vector: Vector3
		match counter:
			0:
				position_vector = Vector3.MODEL_TOP
			1:
				position_vector = Vector3.MODEL_BOTTOM
			2:
				position_vector = Vector3.MODEL_LEFT
			3:
				position_vector = Vector3.MODEL_RIGHT
			4:
				position_vector = Vector3.MODEL_FRONT
			5:
				position_vector = Vector3.MODEL_REAR
		var new_life_orb_node: Node3D = PLAYER_LIFE_ORB.instantiate()
		add_child(new_life_orb_node)
		new_life_orb_node.global_transform = global_transform.translated(position_vector * 0.7)
		player_life_orb_material.set_shader_parameter("Color", player_material.get_shader_parameter("Color"))
		player_life_orb_material.set_shader_parameter("glow_color", player_material.get_shader_parameter("glow_color"))
		player_life_orbs.append(new_life_orb_node)
		counter += 1


func hide_life_orb() -> void:
	for life_orb_node: Node3D in player_life_orbs:
		if life_orb_node.visible:
			life_orb_node.visible = false
			return
