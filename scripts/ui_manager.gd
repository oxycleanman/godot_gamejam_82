class_name UIManager extends Control

@onready var disguise_info_panel: DisguiseInfoPanelManager = %DisguiseInfoPanel
@onready var detected_alert: MarginContainer = %DetectedAlert
@onready var loading_message: MarginContainer = %LoadingMessage
@onready var player_info_panel: PlayerInfoPanelManager = %PlayerInfoPanel
@onready var main_menu_screen: MainMenuScreenManager = %MainMenuScreen
@onready var pause_menu: PauseMenuManager = %PauseMenu
@onready var settings_menu: SettingsMenuManager = %SettingsMenu
@onready var game_end_screen: MarginContainer = %GameEndScreen

var should_show_main_menu: bool = true

# accessibility option to show text-based ui elements for things show through visuals in the game
# like player lives remaining, disguise status, and remaining disguise
var should_show_text_ui_elements: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.refs[Constants.UI_MANAGER] = self
	disguise_info_panel.visible = false
	detected_alert.visible = false
	loading_message.visible = false
	player_info_panel.visible = false
	main_menu_screen.visible = true
	pause_menu.visible = false
	settings_menu.visible = false
	game_end_screen.visible = false


func set_show_text_ui_elements(value: bool) -> void:
	should_show_text_ui_elements = value
	if should_show_main_menu:
		return
	
	if should_show_text_ui_elements:
		player_info_panel.visible = true
		return
	
	player_info_panel.visible = false
	disguise_info_panel.visible = false
	detected_alert.visible = false


func on_player_disguised(value: bool) -> void:
	if should_show_text_ui_elements:
		disguise_info_panel.visible = value
	detected_alert.visible = false


func on_player_disguise_health_changed(new_disguise_health: float) -> void:
	disguise_info_panel.set_disguise_health_bar_value(new_disguise_health)


func on_player_detected() -> void:
	if should_show_text_ui_elements:
		detected_alert.visible = true


func on_goal_reached(show_loading_message: bool = true) -> void:
	disguise_info_panel.visible = false
	disguise_info_panel.set_disguise_health_bar_value(100.0)
	detected_alert.visible = false
	player_info_panel.visible = false
	main_menu_screen.visible = should_show_main_menu
	loading_message.visible = show_loading_message and should_show_text_ui_elements


func on_new_level_loaded() -> void:
	loading_message.visible = false
	disguise_info_panel.visible = false
	disguise_info_panel.set_disguise_health_bar_value(100.0)
	detected_alert.visible = false
	if should_show_text_ui_elements:
		player_info_panel.visible = true


func set_player_lives(value: int) -> void:
	player_info_panel.set_lives_value(value)


func set_should_show_main_menu(value: bool) -> void:
	should_show_main_menu = value


func show_pause_menu() -> void:
	pause_menu.visible = true


func hide_pause_menu() -> void:
	pause_menu.visible = false


func show_settings_menu() -> void:
	settings_menu.visible = true


func hide_settings_menu() -> void:
	settings_menu.visible = false


func set_settings_menu_bg_music_slider(new_value: float) -> void:
	settings_menu.set_background_music_slider_value(new_value)


func set_settings_menu_sound_effect_slider(new_value: float) -> void:
	settings_menu.set_sound_effect_slider_value(new_value)


func set_settings_menu_bg_button_value(new_value: float) -> void:
	settings_menu.set_background_music_toggle_value(new_value)


func set_settings_menu_sound_effect_button_value(new_value: float) -> void:
	settings_menu.set_sound_effect_toggle_value(new_value)


func _on_pause_menu_continue_pressed() -> void:
	print("UIManager -> pause menu continue button pressed")


func _on_pause_menu_quit_pressed() -> void:
	print("UIManager -> pause menu quit button pressed")


func _on_pause_menu_settings_pressed() -> void:
	show_settings_menu()


func _on_settings_menu_settings_back_button_pressed() -> void:
	hide_settings_menu()


func _on_settings_menu_show_ui_text_elements_toggled(value: bool) -> void:
	set_show_text_ui_elements(value)


func reached_end_of_game() -> void:
	disguise_info_panel.visible = false
	detected_alert.visible = false
	loading_message.visible = false
	player_info_panel.visible = false
	main_menu_screen.visible = false
	pause_menu.visible = false
	settings_menu.visible = false
	game_end_screen.visible = true
