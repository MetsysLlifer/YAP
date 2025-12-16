extends Node

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Enter"):
		get_tree().change_scene_to_file("res://Scenes/SceneSwitcher.tscn")


func _start():
	get_tree().change_scene_to_file("res://Scenes/SceneSwitcher.tscn")
