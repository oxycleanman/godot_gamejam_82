class_name SettingsMenuManager extends MarginContainer

signal show_ui_text_elements_toggled(value: bool)
signal background_music_toggled(value: bool)
signal sound_effects_toggled(value: bool)
signal music_volume_changed(new_value: float)
signal sound_effect_volume_changed(new_value: float)
signal settings_back_button_pressed()

@onready var show_text_ui_button: CheckButton = %ShowTextUiButton
@onready var background_music_button: CheckButton = %BackgroundMusicButton
@onready var sound_effects_button: CheckButton = %SoundEffectsButton
@onready var music_volume_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/MarginContainer4/VBoxContainer/MusicVolumeSlider
@onready var sound_effect_volume_slider: HSlider = $PanelContainer/MarginContainer/VBoxContainer/MarginContainer5/VBoxContainer/SoundEffectVolumeSlider


func _on_show_text_ui_button_toggled(toggled_on: bool) -> void:
	show_ui_text_elements_toggled.emit(toggled_on)


func _on_background_music_button_toggled(toggled_on: bool) -> void:
	background_music_toggled.emit(toggled_on)


func _on_sound_effects_button_toggled(toggled_on: bool) -> void:
	sound_effects_toggled.emit(toggled_on)


func _on_music_volume_slider_drag_ended(value_changed: bool) -> void:
	music_volume_changed.emit(music_volume_slider.value)


func _on_sound_effect_volume_slider_drag_ended(value_changed: bool) -> void:
	sound_effect_volume_changed.emit(sound_effect_volume_slider.value)


func _on_back_button_pressed() -> void:
	settings_back_button_pressed.emit()


func set_background_music_slider_value(new_value: float) -> void:
	music_volume_slider.set_value_no_signal(new_value)


func set_background_music_toggle_value(new_value: float) -> void:
	background_music_button.set_pressed_no_signal(new_value)


func set_sound_effect_slider_value(new_value: float) -> void:
	sound_effect_volume_slider.set_value_no_signal(new_value)


func set_sound_effect_toggle_value(new_value: float) -> void:
	sound_effects_button.set_pressed_no_signal(new_value)
