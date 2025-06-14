extends StaticBody3D

@onready var barrel: MeshInstance3D = %Barrel
@onready var sight_range: Area3D = %SightRange
var player: Player

func _physics_process(delta: float) -> void:
	var visible_nodes: Array[Node3D] = sight_range.get_overlapping_bodies()
	for visible_node: Node3D in visible_nodes:
		if visible_node is Player:
			player = visible_node as Player
			if player.currently_disguised:
				break
			
			#barrel.rotate_z()
