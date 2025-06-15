class_name Projectile extends AnimatableBody3D

signal projectile_hit_player()

var speed: float = 2.0
var lifetime_in_seconds: float = 3.0
var player: Player
var velocity: Vector3


func _ready() -> void:
	player = Globals.refs[Constants.PLAYER]
	velocity = global_position * speed
	get_tree().create_timer(lifetime_in_seconds).timeout.connect(_handle_lifetime_end)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or is_queued_for_deletion():
		return
	
	
	var collision_info: KinematicCollision3D = move_and_collide(velocity)
	if not collision_info:
		velocity = global_position.direction_to(player.global_position) * speed * delta
		return
		
	var node_collided_with_rid: RID = collision_info.get_collider_rid()
	
	if node_collided_with_rid == player.get_rid():
		projectile_hit_player.emit()
		queue_free()
		return
		
	velocity = velocity.slide(collision_info.get_normal().normalized()) * speed


func _handle_lifetime_end() -> void:
	queue_free()
