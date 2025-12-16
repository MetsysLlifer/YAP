extends Terror

@onready var cooldown: Timer = $Cooldown
@onready var main = get_tree().current_scene
@onready var projectile = load("res://Objects/Items/kamote_projectile.tscn")

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
	cooldown.timeout.connect(_on_cooldown_timeout)

func _physics_process(_delta: float) -> void:
	if current_target != null:
		track_target()
	if cooldown.is_stopped():
			shoot()
			cooldown.start()
# Projectile Function
func shoot():
	if current_target == null: return
	var instance = projectile.instantiate()
	instance.global_position = global_position
	instance.direction = (current_target.global_position - global_position).normalized()
	instance.add_collision_exception_with(self)
	main.add_child.call_deferred(instance)
	print("Shooting")
	
func _on_cooldown_timeout() -> void:
	shoot()
	
func attack(body: Node) -> void:
	if body.is_in_group("player"):
		body.status.health -= 10
