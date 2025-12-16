extends Node

# Get references to the children nodes
@onready var music_player: AudioStreamPlayer = $musicPlayer
#@onready var sfx_player = $SFXPlayer

# Path to your main menu music
var default_music_path = "res://assets/music/Kevin MacLeod - Itty Bitty 8 Bit  NO COPYRIGHT 8-bit Music.mp3" # CHANGE THIS to your file path!

func _ready():
	# 1. AUTO-PLAY: Start music immediately when game opens
	play_music(default_music_path)
	
	# Optional: Set default volume to 50% (-6 dB is roughly half volume)
	music_player.volume_db = -6

func play_music(path: String):
	# Don't restart if it's already playing the same song
	if music_player.stream and music_player.stream.resource_path == path and music_player.playing:
		return
	
	# Load and play
	var stream = load(path)
	if stream:
		music_player.stream = stream 
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
