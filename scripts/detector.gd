class_name Detector extends Area3D

signal detected_player()


func _on_body_entered(body: Node3D) -> void:
	if body is Player and not body.currently_disguised:
		print("DETECTED")
		detected_player.emit()
