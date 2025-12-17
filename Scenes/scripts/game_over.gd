extends CanvasLayer

@onready var menus: Control = $menus
# We will store the RESOURCE here, not just the player node.
# Resources don't disappear when the player dies.
var player_data_resource: Resource 

func _ready():
	visible = false
	
	# Find the player to connect signals
	var player_node = get_tree().get_first_node_in_group("player")
	
	if player_node:
		# 1. Capture the Data Resource immediately!
		player_data_resource = player_node.status
		
		# Connect to the death signal
		if player_node.status.has_signal("died"):
			player_node.status.died.connect(toggle_death)

func toggle_death():
	# 1. Pause the game
	get_tree().paused = true
	
	# 2. Show the menu
	visible = true
	menus.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# 3. PLAY GAME OVER MUSIC
	if typeof(audioManager) != TYPE_NIL:
		audioManager.play_music("game_over")

func _on_start_over_pressed() -> void:
	get_tree().paused = false
	
	# 2. Reset the DATA (using the stored resource variable)
	# This works even if 'player_node' is deleted!
	if player_data_resource and player_data_resource.has_method("reset_data"):
		player_data_resource.reset_data()
	else:
		print("Error: Could not find PlayerData to reset.")
	
	# Reload the main scene
	get_tree().change_scene_to_file("res://Scenes/SceneSwitcher.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
