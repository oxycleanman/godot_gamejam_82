class_name AudioManager extends Node

@onready var background_music_player: AudioStreamPlayer = %BackgroundMusicPlayer

var loop_background_music: bool = true

func _ready() -> void:
	background_music_player.finished.connect(_handle_background_music_finished)


func _handle_background_music_finished() -> void:
	if loop_background_music:
		background_music_player.play()
