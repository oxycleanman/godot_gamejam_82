class_name PauseMenuManager extends MarginContainer

signal continue_pressed()
signal settings_pressed()
signal quit_pressed()


func _on_continue_button_pressed() -> void:
	continue_pressed.emit()


func _on_settings_button_pressed() -> void:
	settings_pressed.emit()


func _on_quit_button_pressed() -> void:
	quit_pressed.emit()
