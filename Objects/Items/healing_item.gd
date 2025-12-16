extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@export var status : Healing

func _ready() -> void:
	connect("body_entered", collect_item)
	sprite_2d.texture = status.texture

func collect_item(body: Node) -> void:
	# Assuming 'body.status' is your PlayerData resource
	if body.is_in_group("player") and body.status:
		# Try to add to inventory
		var was_added = body.status.add_item(status)
		
		# Only destroy the object if it was actually picked up
		if was_added:
			queue_free()
		else:
			print("Inventory is full!")
