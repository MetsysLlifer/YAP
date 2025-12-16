extends CanvasLayer

@onready var menus: VBoxContainer = $menus
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
	menus.visible = true
	options.visible = false
	h_slider.value = db_to_linear(audioManager.music_player.volume_db)
	

# --- CONNECT THESE SIGNALS NEXT ---

func _on_resume_pressed() -> void:
	toggle_pause() # Unpause and hide


func _on_exit_pressed() -> void:
	get_tree().quit() # Close the game window


func _on_options_pressed() -> void:
	menus.visible = false
	options.visible = true # Replace with function body.


func _on_close_pressed() -> void:
	menus.visible = true
	options.visible = false # Replace with function body.


func _on_h_slider_value_changed(value: float) -> void:
	audioManager.set_music_volume(value) # Replace with function body.
