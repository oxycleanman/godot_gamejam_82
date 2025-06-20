class_name MainMenuScreenManager extends MarginContainer

signal start_game_clicked()


func _on_start_button_pressed() -> void:
	start_game_clicked.emit()
