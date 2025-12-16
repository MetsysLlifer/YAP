extends CharacterBody2D

@export var speed: float = 120.0
var direction: Vector2 = Vector2.ZERO

func _ready():
	if direction != Vector2.ZERO:
		rotation = direction.angle()

func _physics_process(_delta) -> void:
	velocity = direction * speed
	move_and_slide()
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		
		if body.is_in_group("player"):
			body.status.health -= 5
			queue_free()  
			return
		else:
			queue_free()
			return
