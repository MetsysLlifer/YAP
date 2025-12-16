class_name EnemyData
extends CharacterData

@export_group("AI Behavior")
# Intensity of the force to bounce back when colliding with objects
@export_range(1, 100000) var avoidance_strength := 21000.0

# Detection range for seeing the player
@export var detection_radius := 300.0
