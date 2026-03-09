extends Node

#const PENA_CUTSCENE := preload("res://Scenes/Animation/PenaCutScene.tscn")
#const GODWIN_CUTSCENE := preload("res://Scenes/Animation/GodwinCutScene.tscn")
#const CHESTRE_CUTSCENE := preload("res://Scenes/Animation/ChestreCutScene.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Enter"):
		get_tree().change_scene_to_file("res://Scenes/SceneSwitcher.tscn")

# START MAIN GAME
func _start():
	get_tree().change_scene_to_file("res://Scenes/SceneSwitcher.tscn")

#ARGUMENT "PENA, GODWIN, OR CHESTRE" CUTSCENE
func spawn_cutscene(scene: PackedScene):
	var cutscene_instance = scene.instantiate()
	add_child(cutscene_instance)
