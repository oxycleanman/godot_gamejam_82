class_name GameManager extends Node3D

@onready var detected_alert: MarginContainer = %DetectedAlert
var info_panel: InfoPanelManager


func _ready() -> void:
	Globals.refs[Constants.GAME_MANAGER] = self
	info_panel = Globals.refs.get(Constants.INFO_PANEL)
	info_panel.visible = false
	detected_alert.visible = false


func _on_player_disguised(value: bool) -> void:
	info_panel.visible = value
	detected_alert.visible = false


func _on_player_disguise_health_changed(new_disguise_health: float) -> void:
	info_panel.set_disguise_health_bar_value(new_disguise_health)


func _on_detector_detected_player() -> void:
	detected_alert.visible = true
