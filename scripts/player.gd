class_name Player extends CharacterBody3D

signal player_disguised(value: bool)
signal player_disguise_health_changed(new_disguise_health: float)

@export var starting_material_color: Color
@export var player_material: StandardMaterial3D

var speed: int = 5
var drag_when_stopping: float = 0.03
var input_vector: Vector2 = Vector2.ZERO
var movement_direction: Vector2 = Vector2.ZERO
var currently_disguised: bool = false:
	set(value):
		currently_disguised = value
		player_disguised.emit(currently_disguised)
var disguise_damage_from_movement: float = 1.0
var current_disguise_health: float = 5.0
var max_disguise_health: float = 5.0

func _ready() -> void:
	Globals.refs[Constants.PLAYER] = self
	player_material.emission = starting_material_color


func _unhandled_input(_event: InputEvent) -> void:
	input_vector = Input.get_vector(Constants.MOVE_LEFT, Constants.MOVE_RIGHT, Constants.MOVE_DOWN, Constants.MOVE_UP)


func _physics_process(delta: float) -> void:
	if input_vector.is_zero_approx():
		movement_direction = movement_direction.move_toward(Vector2.ZERO, drag_when_stopping)
	else:
		movement_direction = input_vector
		_handle_disguise_degredation(delta)
	
	velocity = Vector3(movement_direction.x * speed, movement_direction.y * speed, 0.0)
	
	var collided_during_movement: bool = move_and_slide()


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
		player_material.emission = starting_material_color


func disguise_player(color: Color) -> void:
	currently_disguised = true
	player_disguise_health_changed.emit(remap(current_disguise_health, 0.0, max_disguise_health, 0.0, 100.0))
	player_material.emission = color
	
