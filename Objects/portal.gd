extends Area2D

@onready var cooldown: Timer = %Cooldown
@onready var collision: CollisionShape2D = %collision

signal scene_changed(current_scene_name: String, entry_tag: String)
@export var entry_tag: String = "Default_Spawn"

# 0 = White (Open), 1 = Red (Locked), 2 = Green (Completed & Locked)
var current_status: int = 0 

func _ready() -> void:
	collision.disabled = true
	cooldown.one_shot = true
	if not cooldown.timeout.is_connected(portal_activate):
		cooldown.timeout.connect(portal_activate)
	cooldown.start()
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func portal_activate() -> void:
	collision.set_deferred("disabled", false)
	# print("Portal is now active!")

# --- COLOR & STATUS LOGIC ---
func set_portal_status(status_code: int) -> void:
	current_status = status_code
	
	match current_status:
		0: # WHITE (Normal / Open)
			modulate = Color(1, 1, 1) 
		1: # RED (Locked / Restricted)
			modulate = Color(1, 0.3, 0.3)
		2: # GREEN (Completed / Done)
			modulate = Color(0.3, 1, 0.3)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		
		# Check Lock Status
		if current_status == 1:
			print("Locked! Tasks not finished or prerequisite not met.")
			return
		elif current_status == 2:
			print("Completed! You have already finished this area.")
			return

		# If Status is 0 (White), proceed
		var current_scene_name = owner.name.to_lower()
		print("Leaving scene: ", current_scene_name)
		scene_changed.emit(current_scene_name, entry_tag)
