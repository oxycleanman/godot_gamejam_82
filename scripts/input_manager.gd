extends Node

signal pause_button_pressed()
signal escape_button_pressed()


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(Constants.PAUSE):
		pause_button_pressed.emit()
	if Input.is_action_just_pressed(Constants.ESCAPE):
		escape_button_pressed.emit()
