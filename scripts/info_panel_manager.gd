class_name InfoPanelManager extends MarginContainer

@onready var progress_bar: ProgressBar = %ProgressBar

func _ready() -> void:
	Globals.refs[Constants.INFO_PANEL] = self


func set_disguise_health_bar_value(value: float) -> void:
	progress_bar.value = value
