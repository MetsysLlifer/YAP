extends Node

# Get references to the children nodes
@onready var music_player: AudioStreamPlayer = $musicPlayer
var lobby_music = preload("res://Scenes/Audio/Kevin MacLeod - Itty Bitty 8 Bit  NO COPYRIGHT 8-bit Music.mp3")
var boss_music = preload("res://Scenes/Audio/boss.mp3")
var game_over_music = preload("res://Scenes/Audio/died.mp3")
#@onready var sfx_player = $SFXPlayer

# Path to your main menu music
var default_music_path = "res://Scenes/Audio/Kevin MacLeod - Itty Bitty 8 Bit  NO COPYRIGHT 8-bit Music.mp3"

func _ready():
	# 1. AUTO-PLAY: Start music immediately when game opens
	play_music(default_music_path)
	
	# Optional: Set default volume to 50% (-6 dB is roughly half volume)
	music_player.volume_db = -6

func play_music(type: String) -> void:
	var stream_to_play = null
	
	match type:
		"boss":
			stream_to_play = boss_music
		"game_over":  # <--- NEW CASE
			stream_to_play = game_over_music
		_:
			# Default to lobby for everything else
			stream_to_play = lobby_music
	# Only switch tracks if it's actually different
	if music_player.stream != stream_to_play:
		music_player.stream = stream_to_play
		music_player.play()
	
	# Only change if the song is actually different
	if music_player.stream != stream_to_play:
		music_player.stream = stream_to_play
		music_player.play()


#func play_sfx(path: String):
	#var stream = load(path)
	#if stream:
		#sfx_player.stream = stream
		#sfx_player.play()

# --- THIS IS THE FUNCTION FOR THE SLIDER ---
func set_music_volume(value: float):
	# The slider gives a value between 0.0 and 1.0
	# We use linear_to_db() to convert it to Godot's volume system
	music_player.volume_db = linear_to_db(value)
