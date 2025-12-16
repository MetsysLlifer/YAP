class_name Task
extends Resource

@export_group("Basic Information")
@export var item_name: String = "Unknown"
@export_enum("network", "notebook", "bug") var icon_type: String = "network"

@export var texture : Dictionary[String, Texture2D] = {
	"network": preload("res://assets/base/network.png"),
	"notebook": preload("res://assets/base/notebook.png"),
	"bug": preload("res://assets/base/bug.png")
	}


# 3. Helper function to give the actual image to the game
func get_texture() -> Texture2D:
	if texture.has(icon_type):
		return texture[icon_type]
	return null
