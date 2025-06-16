class_name Detector extends Area3D

signal detected_player()
signal player_reached_goal()
signal player_hit_hazard()

@export_enum("Alert", "Collectable", "Goal", "Hazard") var detector_type: String


func _on_body_entered(body: Node3D) -> void:
	match detector_type:
		"Alert":
			_handle_alert_detection(body)
		"Collectable":
			_handle_collectible_detection(body)
		"Goal":
			_handle_goal_detection(body)
		"Hazard":
			_handle_hazard_detection(body)


func _handle_alert_detection(body: Node3D) -> void:
	if body is Player and not body.currently_disguised:
		detected_player.emit()


func _handle_collectible_detection(_body: Node3D) -> void:
	print("Picked up collectable")


func _handle_goal_detection(body: Node3D) -> void:
	if body is Player:
		player_reached_goal.emit()

func _handle_hazard_detection(body: Node3D) -> void:
	if body is Player:
		player_hit_hazard.emit()
		body.push_player_back()
		queue_free()
