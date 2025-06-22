class_name AudioManager extends Node

signal audio_manager_bg_music_started(new_value: float)
signal audio_manager_sound_effect_started(new_value: float)

@onready var background_music_player: AudioStreamPlayer = %BackgroundMusicPlayer

var loop_background_music: bool = true
var should_play_sound_effects: bool = true
var sound_effect_volume_linear: float = 5.0

func _ready() -> void:
	Globals.refs[Constants.AUDIO_MANAGER] = self
	background_music_player.finished.connect(_handle_background_music_finished)
	print("Background music player current volume linear: ", background_music_player.volume_linear)
	# initialize the UI elements so they start in the correct state
	# would have been nice if I actually got to persisting these settings
	audio_manager_bg_music_started.emit.call_deferred(background_music_player.volume_linear)
	audio_manager_sound_effect_started.emit.call_deferred(sound_effect_volume_linear)


func _handle_background_music_finished() -> void:
	if loop_background_music:
		background_music_player.play()


func _on_settings_menu_background_music_toggled(should_play: bool) -> void:
	if not should_play:
		background_music_player.stop()
		loop_background_music = false
		return
	
	background_music_player.play()
	loop_background_music = true


func _on_settings_menu_music_volume_changed(new_value: float) -> void:
	print("Background music player current volume linear: ", background_music_player.volume_linear)
	background_music_player.volume_linear = new_value


func _on_settings_menu_sound_effect_volume_changed(new_value: float) -> void:
	sound_effect_volume_linear = new_value


func _on_settings_menu_sound_effects_toggled(value: bool) -> void:
	should_play_sound_effects = value


func get_should_play_sound_effects() -> bool:
	return should_play_sound_effects


func get_sound_effect_volume_linear() -> float:
	return sound_effect_volume_linear
