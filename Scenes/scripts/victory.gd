extends Control

func _ready() -> void:
	# Hide automatically when the game starts
	visible = false

func show_popup() -> void:
	visible = true
	# Optional: Play a sound or animation here
	get_tree().paused = true
	print("Victory Popup Shown")

func _on_continue_pressed() -> void:
	# Hide the popup so the player can walk out
	visible = false

func _on_button_pressed() -> void:
	pass # Replace with function body.
