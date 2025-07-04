class_name Turret extends StaticBody3D

signal fired_projectile(projectile: Projectile)

const PROJECTILE: PackedScene = preload("res://scenes/game_objects/projectile.tscn")

@onready var projectile_spawn_point: Marker3D = %ProjectileSpawnPoint
@onready var mesh: MeshInstance3D = %Mesh

@export var detection_distance: float = 50.0
@export var material_config: CellShaderConfig

var player: Player
var projectile: Projectile

func _ready() -> void:
	Helpers.set_shader_instance_params(mesh, material_config)
	_setup.call_deferred()


func _setup() -> void:
	player = Globals.refs[Constants.PLAYER]


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		return
	
	var current_player_position: Vector3 = player.global_position
	var distance_to_player: float = global_position.distance_squared_to(current_player_position)
	if distance_to_player <= detection_distance:
		#print("Player within detection distance of turret")
		if not player.currently_disguised:
			if is_instance_valid(projectile):
				return
			
			var projectile_node: Node3D = PROJECTILE.instantiate()
			projectile = projectile_node as Projectile
			get_tree().current_scene.get_node("%GameWorld").add_child(projectile_node)
			projectile_node.global_position = projectile_spawn_point.global_position
			fired_projectile.emit(projectile)
