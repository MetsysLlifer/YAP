class_name PlayerData
extends CharacterData

@export_group("Player Specifics")
@export var stamina: float = 100.0
@export var experience: int = 0

@export_group("Inventory")
# We use an Array of size 2 for your 2 slots. 
# null = empty slot.
@export var inventory: Array[Resource] = [null, null]

signal inventory_updated

# Helper function to add an item to the first empty slot
func add_item(item: Resource) -> bool:
	for i in range(inventory.size()):
		if inventory[i] == null:
			inventory[i] = item
			emit_signal("inventory_updated")
			return true # Successfully added
	return false # Inventory is full

func remove_item(index: int) -> void:
	if index >= 0 and index < inventory.size():
		inventory[index] = null
		emit_signal("inventory_updated")
