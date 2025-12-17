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

func reset_data() -> void:
	# 1. Reset Health (Change 100.0 to your actual max health)
	health = 75
	
	# 2. Clear Inventory (Change size based on your slots, e.g., 2 slots)
	inventory = [null, null] 
	
	# 3. Notify the game that data changed
	emit_signal("health_changed", health)
	emit_signal("inventory_updated")
