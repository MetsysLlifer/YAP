extends Terror


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
