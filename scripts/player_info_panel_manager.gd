class_name PlayerInfoPanelManager extends MarginContainer

@onready var lives_value: Label = %LivesValue


func set_lives_value(value: int) -> void:
	lives_value.text = str(value)
