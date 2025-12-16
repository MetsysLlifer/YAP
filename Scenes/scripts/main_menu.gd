extends Control

@onready var menus: VBoxContainer = $menus
@onready var options: Panel = $options
@onready var h_slider: HSlider = $options/HSlider


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menus.visible = true
	options.visible = false
	h_slider.value = db_to_linear(audioManager.music_player.volume_db)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Animation/intro.tscn") # Replace with function body.

func _on_option_pressed() -> void:
	menus.visible = false
	options.visible = true
	 # Replace with function body.


func _on_exit_pressed() -> void:
	get_tree().quit() # Replace with function body.


func _on_close_pressed() -> void:
	menus.visible = true
	options.visible = false
	 # Replace with function body.


func _on_h_slider_value_changed(value: float) -> void:
	audioManager.set_music_volume(value) # Replace with function body.
