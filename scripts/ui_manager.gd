class_name UIManager extends Control

@onready var disguise_info_panel: DisguiseInfoPanelManager = %DisguiseInfoPanel
@onready var detected_alert: MarginContainer = %DetectedAlert
@onready var loading_message: MarginContainer = %LoadingMessage
@onready var player_info_panel: PlayerInfoPanelManager = %PlayerInfoPanel
@onready var main_menu_screen: MainMenuScreenManager = %MainMenuScreen

var should_show_main_menu: bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.refs[Constants.UI_MANAGER] = self
	disguise_info_panel.visible = false
	detected_alert.visible = false
	loading_message.visible = false
	player_info_panel.visible = false
	main_menu_screen.visible = true


func on_player_disguised(value: bool) -> void:
	disguise_info_panel.visible = value
	detected_alert.visible = false


func on_player_disguise_health_changed(new_disguise_health: float) -> void:
	disguise_info_panel.set_disguise_health_bar_value(new_disguise_health)


func on_player_detected() -> void:
	detected_alert.visible = true


func on_goal_reached(show_loading_message: bool = true) -> void:
	disguise_info_panel.visible = false
	disguise_info_panel.set_disguise_health_bar_value(100.0)
	detected_alert.visible = false
	#player_info_panel.visible = false
	main_menu_screen.visible = should_show_main_menu
	loading_message.visible = show_loading_message


func on_new_level_loaded() -> void:
	loading_message.visible = false
	disguise_info_panel.visible = false
	disguise_info_panel.set_disguise_health_bar_value(100.0)
	detected_alert.visible = false
	#player_info_panel.visible = true


func set_player_lives(value: int) -> void:
	player_info_panel.set_lives_value(value)


func set_should_show_main_menu(value: bool) -> void:
	should_show_main_menu = value
