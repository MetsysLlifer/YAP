extends Turret

# --- NEW VARIABLES (Specific to shooting) ---
@onready var cooldown: Timer = $Cooldown
@onready var main = get_tree().current_scene
@onready var projectile = load("res://Objects/Items/error_projectile.tscn")

func _ready() -> void:
	# 1. Run the Parent's setup first!
	# This handles the Raycast creation, signal connections, and status setup automatically.
	super() 
	
	# 2. Add our specific turret setup
	if has_node("Cooldown"):
		cooldown.timeout.connect(shoot)

func _physics_process(delta: float) -> void:
	# 1. Run Parent's logic (checks if target exists, calls track_target)
	super(delta)
	
	# 2. Add Shooting Logic
	if current_target != null and cooldown.is_stopped():
		shoot()
		cooldown.start()

# --- THE IMPORTANT PART: OVERRIDE MOVEMENT ---
func track_target() -> void:
	# We copy the AIMING math from Terror...
	var direction = pointer.global_position.direction_to(current_target.global_position)
	var distance = pointer.global_position.distance_to(current_target.global_position)
	
	pointer.target_position = Vector2(distance, 0)
	pointer.rotation = direction.angle()
	
	# ...and the Visual Flip...
	if sprite_2d:
		sprite_2d.flip_h = true if direction.x < 0 else false

	# ...BUT WE DELETE THE MOVEMENT CODE.
	# Since we don't write 'velocity =' or 'move_and_slide()', it stays still.

# --- SHOOTING FUNCTION ---
func shoot() -> void:
	if current_target == null: return
	
	var instance = projectile.instantiate()
	instance.global_position = global_position
	instance.direction = (current_target.global_position - global_position).normalized()
	instance.add_collision_exception_with(self)
	main.add_child.call_deferred(instance)
