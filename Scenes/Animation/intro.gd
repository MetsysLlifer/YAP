extends Node

@onready var animationIntro = $%AnimationPlayer
@onready var fastForwardButton = $%FastForward
@onready var skipButton = $%Skip

# Define your speed multipliers here so they are easy to tweak later
const NORMAL_SPEED: float = 1.0
const FAST_SPEED: float = 3.0

#const PENA_CUTSCENE := preload("res://Scenes/Animation/PenaCutScene.tscn")
#const GODWIN_CUTSCENE := preload("res://Scenes/Animation/GodwinCutScene.tscn")
#const CHESTRE_CUTSCENE := preload("res://Scenes/Animation/ChestreCutScene.tscn")

func _ready() -> void:
	# Set pivot points to the center so the buttons shrink towards their middle
	skipButton.pivot_offset = skipButton.size / 2
	fastForwardButton.pivot_offset = fastForwardButton.size / 2

	# Connect the UI buttons to their respective functions
	skipButton.pressed.connect(_skip_cutscene)
	fastForwardButton.button_down.connect(_enable_fast_forward)
	fastForwardButton.button_up.connect(_disable_fast_forward)

func _input(event: InputEvent) -> void:
	# Handle Skip (Enter)
	if event.is_action_pressed("Enter"):
		_skip_cutscene()
		
	# Handle Fast Forward (Space) - Hold to fast forward, release for normal speed
	if event.is_action_pressed("Space"):
		_enable_fast_forward()
	elif event.is_action_released("Space"):
		_disable_fast_forward()

func _skip_cutscene() -> void:
	# Animate the skip button shrinking slightly for visual feedback
	var tween = create_tween()
	tween.tween_property(skipButton, "scale", Vector2(0.85, 0.85), 0.1)
	
	# Wait for the animation to finish (0.1s delay), THEN run the start function
	tween.finished.connect(_start)

func _enable_fast_forward() -> void:
	# Visually press the button down (shrink it)
	var tween = create_tween()
	tween.tween_property(fastForwardButton, "scale", Vector2(0.85, 0.85), 0.1)
	
	# Speed up the animation
	if animationIntro:
		animationIntro.speed_scale = FAST_SPEED

func _disable_fast_forward() -> void:
	# Visually release the button (return to normal size)
	var tween = create_tween()
	tween.tween_property(fastForwardButton, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Return the animation to normal speed
	if animationIntro:
		animationIntro.speed_scale = NORMAL_SPEED

# START MAIN GAME
func _start():
	get_tree().change_scene_to_file("res://Scenes/SceneSwitcher.tscn")

#ARGUMENT "PENA, GODWIN, OR CHESTRE" CUTSCENE
func spawn_cutscene(scene: PackedScene):
	var cutscene_instance = scene.instantiate()
	add_child(cutscene_instance)
