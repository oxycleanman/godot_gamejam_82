class_name Detector extends Area3D

signal detected_player()
signal player_reached_goal()

@export_enum("Alert", "Collectable", "Goal") var detector_type: String


func _on_body_entered(body: Node3D) -> void:
	match detector_type:
		"Alert":
			_handle_alert_detection(body)
		"Collectable":
			_handle_collectible_detection(body)
		"Goal":
			_handle_goal_detection(body)


func _handle_alert_detection(body: Node3D) -> void:
	if body is Player and not body.currently_disguised:
		print("DETECTED")
		detected_player.emit()


func _handle_collectible_detection(_body: Node3D) -> void:
	print("Picked up collectable")


func _handle_goal_detection(body: Node3D) -> void:
	if body is Player:
		print("Player reached goal")
		player_reached_goal.emit()
