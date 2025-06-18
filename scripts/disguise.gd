class_name Disguise extends MeshInstance3D


@export var emission_color: Color = Color.RED
var player: Player


func _ready() -> void:
	_setup.call_deferred()


func _setup() -> void:
	player = Globals.refs.get(Constants.PLAYER)


func _on_area_3d_body_entered(_body: Node3D) -> void:
	player.disguise_player(emission_color)
	queue_free()
