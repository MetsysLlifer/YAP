extends CanvasLayer

@onready var menus: VBoxContainer = $menus
@onready var options: Panel = $options
@onready var player_node 

func _ready():
	# 1. Hide the menu as soon as the game loads
	visible = false
	player_node = owner.find_child("Player")
	owner.player_changed.connect(updatePlayer)
	player_node.status.died.connect(toggle_death)

func updatePlayer(next_player):
	player_node = next_player
	# Re-connect health signals if needed here as well
	
func toggle_death():
	# 3. Flip the pause state (True becomes False, False becomes True)
	var is_paused = !get_tree().paused
	# 4. Freeze or Unfreeze the game
	get_tree().paused = is_paused
	
	# 5. Show or Hide this menu
	visible = is_paused
	menus.visible = true
	

# --- CONNECT THESE SIGNALS NEXT ---

func _on_start_over_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/SceneSwitcher.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit() # Close the game window

func _on_h_slider_value_changed(value: float) -> void:
	audioManager.set_music_volume(value) # Replace with function body.
