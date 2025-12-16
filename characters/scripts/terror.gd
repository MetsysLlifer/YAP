extends CharacterBody2D
class_name Terror

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var field: Area2D = $Field
@onready var hitbox: Area2D = $HitBox
@export var status: EnemyData

# We will store the variables directly here to avoid "status" confusion
var current_target: Node2D = null
var pointer: RayCast2D = null

func _ready() -> void:
	if not status:
		status = EnemyData.new()
	# 1. Create the Raycast ONCE when the game starts
	pointer = RayCast2D.new()
	add_child(pointer)
	pointer.enabled = true # Important!
	
	# 2. Connect signals
	field.body_entered.connect(get_object_reference)
	field.body_exited.connect(remove_object_reference)
	hitbox.body_entered.connect(attack)

func _physics_process(_delta: float) -> void:
	# Only run if we actually have a valid target
	if current_target != null:
		track_target()

func track_target() -> void:
	# Update Raycast rotation and length
	var direction = pointer.global_position.direction_to(current_target.global_position)
	var distance = pointer.global_position.distance_to(current_target.global_position)
	var intensity = get_arrival_intensity(current_target)
	
	pointer.target_position = Vector2(distance, 0)
	pointer.rotation = direction.angle()
	
	# Move the character
	# Note: Moving by 'global_position' is usually wrong (that's teleporting).
	# You usually want to move by direction * speed.
	velocity = direction * (status.speed * intensity)
	
	sprite_2d.flip_h = true if velocity.x < 0 else false
	move_and_slide()

func get_object_reference(object: Node2D) -> void:
	# If it is a player, make it the current target
	if object.is_in_group("player"):
		current_target = object

func remove_object_reference(object: Node2D) -> void:
	# Only remove if the object leaving IS the one we are chasing
	if object == current_target:
		current_target = null
		# Optional: Reset velocity when target is lost
		velocity = Vector2.ZERO


# Returns a value between 0.0 (stopped) and 1.0 (full speed)
func get_arrival_intensity(target: Node2D) -> float:
	# The distance (in pixels) where the enemy starts hitting the brakes
	var slow_down_radius := 50.0 
	
	# Calculate pure distance
	var distance := global_position.distance_to(target.global_position)
	
	# Calculate intensity: 
	# If distance is 200 (radius), intensity >= 1.
	var intensity := distance / slow_down_radius - 1
	
	# Clamp ensures we never go above 1.0 (overspeeding) or below -1.0 (reversing)
	return clampf(intensity, -1.0, 1.0)

func attack(body: Node) -> void:
	if body.is_in_group("player"):
		body.status.health -= 10
