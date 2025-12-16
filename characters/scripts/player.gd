extends CharacterBody2D



@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var status : CharacterData

var steering_factor := 10.0

func _ready() -> void:
	if not status:
		status = CharacterData.new()

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	var desired_velocity := status.max_speed * direction
	var steering_vector := desired_velocity - velocity
	velocity += steering_vector * steering_factor * delta
	position += velocity * delta
	move_and_slide()
	# 2. Updated Animation Logic
	if direction.length() > 0.0:
		# If moving, force the loop to be active
		var animation = animation_player.get_animation("walk")
		animation.loop_mode = Animation.LOOP_LINEAR # Ensure it loops
		animation_player.play("walk")
	else:
		# If stopping, tell the animation to STOP LOOPING but keep playing
		# This allows the current cycle to finish, then it will stop automatically.
		var animation = animation_player.get_animation("walk")
		animation.loop_mode = Animation.LOOP_NONE
	
	sprite_2d.flip_h = true if velocity.x < 0 else false

func equip_item(_index):
	#var item = Sprite2D.new()
	#item.texture = preload("res://assets/base/handnotebook.png")
	#add_child(item)
	print("NIGGA")
