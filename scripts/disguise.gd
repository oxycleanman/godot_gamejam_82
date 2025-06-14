class_name Disguise extends MeshInstance3D


@export var emission_color: Color = Color.RED
@export var material: StandardMaterial3D
var player: Player


func _ready() -> void:
	_setup.call_deferred()


func _setup() -> void:
	player = Globals.refs.get(Constants.PLAYER)
	material.emission = emission_color


func _on_area_3d_body_entered(body: Node3D) -> void:
	player.disguise_player(emission_color)
	queue_free()
