class_name EnemyData
extends CharacterData

@export_group("AI Behavior")
# Intensity of the force to bounce back when colliding with objects
@export_range(0.0, 1.0) var avoidance_strength : float = 0.0

# Detection range for seeing the player
@export var detection_radius := 300.0
