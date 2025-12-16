extends CharacterBody2D


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var item: Sprite2D = $Item

@export var status : PlayerData
var steering_factor := 10.0
# remember which slot we are holding
var active_slot_index: int = -1


func _ready() -> void:
	if not status:
		status = PlayerData.new()

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
	if velocity.x < 0:
		sprite_2d.flip_h = true
		item.position.x = -abs(item.position.x)
	elif velocity.x > 0:
		sprite_2d.flip_h = false
		# Force item to the RIGHT side (positive absolute value)
		item.position.x = abs(item.position.x)

func equip_item(index):
	# Get the item data from the inventory
	var item_resource = status.inventory[index]
	# Check: Is it a real item? AND Does it have a texture?
	if item_resource != null and item_resource.texture != null:
		item.texture = item_resource.texture
	else:
		# If slot is empty (or item has no picture), show nothing
		item.texture = null


func unequip_item():
	active_slot_index = -1
	item.texture = null


func use_equipped_item():
	# 1. Check if we are actually holding something
	if active_slot_index == -1:
		return
	var item_resource = status.inventory[active_slot_index]
	# 2. Check if the item exists and is a Healing item
	# We use "is Healing" to check the class_name you created
	if item_resource and item_resource is Healing:
		# 3. Apply the Heal
		status.health += item_resource.healing_factor
		print("Used item! Health is now: ", status.health)
		# 4. Consume the item (Remove from data)
		status.remove_item(active_slot_index)
		# 5. Clear the visual immediately
		# (The UI will update automatically because of the signal in PlayerData)
		unequip_item()
