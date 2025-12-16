extends CanvasLayer

@onready var menu: HBoxContainer = $menu
@onready var options: Panel = $options
@onready var h_slider: HSlider = $options/HSlider

func _ready():
	# 1. Hide the menu as soon as the game loads
	visible = false 

func _input(event):
	# 2. Listen for the "ui_cancel" key (Escape Key)
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	# 3. Flip the pause state (True becomes False, False becomes True)
	var is_paused = !get_tree().paused
	
	# 4. Freeze or Unfreeze the game
	get_tree().paused = is_paused
	
	# 5. Show or Hide this menu
	visible = is_paused
	menu.visible = true
	options.visible = false
	h_slider.value = db_to_linear(audioManager.music_player.volume_db)
	

# --- CONNECT THESE SIGNALS NEXT ---

func _on_resume_pressed() -> void:
	toggle_pause() # Unpause and hide


func _on_exit_pressed() -> void:
	get_tree().quit() # Close the game window


func _on_options_pressed() -> void:
	menu.visible = false
	options.visible = true # Replace with function body.


func _on_close_pressed() -> void:
	menu.visible = true
	options.visible = false # Replace with function body.


func _on_h_slider_value_changed(value: float) -> void:
	audioManager.set_music_volume(value) # Replace with function body.


func _on_restart_pressed() -> void:
	# 1. Unpause first
	get_tree().paused = false
	
	# 2. Find the Player anywhere in the game (using Group)
	var player = get_tree().get_first_node_in_group("player")
	
	# 3. Reset the Data if player exists
	if player and player.status and player.status.has_method("reset_data"):
		player.status.reset_data()
	else:
		# Fallback: If player is missing, try to force load the resource if you know the path
		# (Only use this line if you have a specific .tres file you use)
		# load("res://Resources/PlayerData.tres").reset_data() 
		print("Warning: Could not find player to reset data.")
	
	# 4. Reload the Main Scene
	# This wipes the SceneSwitcher memory (task progress, etc.)
	get_tree().change_scene_to_file("res://Scenes/SceneSwitcher.tscn")
