class_name CharacterData
extends Resource

# --- Shared Stats ---
@export_group("Movement")
@export_range(100, 2000) var max_speed: float = 100
@export_range(50, 2000) var speed: float = 50
@export var accelerate := 1200.0
@export var decelerate := 1000.0
@export var ground_friction_factor := 10.0 # Fixed typo "fiction" to "friction"

# 1. Define a signal that anyone can listen to
signal health_changed(new_value: int)
signal died

@export_group("Status")
@export_range(0, 1000) var health: int = 100:
	set(value):
		# Clamp value so it never goes below 0
		var clamped_value = clampi(value, 0, 100)
		# Only update if the value is actually different
		if health != clamped_value:
			health = clamped_value
			# Shout to the world: "My health is now X!"
			health_changed.emit(health)
			
			if health == 0:
				died.emit()

@export_range(0, 1000) var attack: int = 100
@export_range(0, 1000) var dexterity: int


enum STATES {IDLE, WALK, WORK}
