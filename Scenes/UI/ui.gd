extends CanvasLayer

@onready var health_bar: ProgressBar = %HealthBar
@onready var slots_container: HBoxContainer = $HBoxContainer
@onready var quest_label: Label = $QuestLabel 
@onready var victory_popup = $Victory
# Get all children of the container (Slot1, Slot2) as an array
@onready var slots: Array = slots_container.get_children()

@onready var label: Label = $Label
var player: CharacterBody2D
# Start with -1. This means "No slot is selected"
var current_slot_index: int = -1 

func _ready() -> void:
	player = owner.find_child("Player")
	owner.player_changed.connect(updatePlayer)
	
	if player:
		if player.status.has_signal("health_changed"):
			player.status.health_changed.connect(updateHealth)
		health_bar.value = player.status.health
		
		# Connect to inventory updates
		if player.status.has_signal("inventory_updated"):
			player.status.inventory_updated.connect(update_inventory_visuals)
			# Run it once to load any starting items
			update_inventory_visuals()
			
	# Update label text initially
	updateHealth(player.status.health)

	for i in range(slots.size()):
		var slot_button = slots[i]
		if slot_button.has_signal("pressed"):
			# Bind the index so we know which button was pressed
			slot_button.pressed.connect(_on_slot_pressed.bind(i))
	
	# Start with nothing selected
	deselect_all()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			_on_slot_pressed(0)
		elif event.keycode == KEY_2:
			_on_slot_pressed(1)

func _on_slot_pressed(index: int) -> void:
	# LOGIC CHECK: Are we clicking the slot that is ALREADY active?
	if current_slot_index == index:
		# Yes -> So turn it OFF (toggle)
		deselect_all()
	else:
		# No -> So turn it ON (select)
		select_slot(index)

func select_slot(index: int) -> void:
	current_slot_index = index
	
	# Visuals: Press the correct button, unpress the others
	for i in range(slots.size()):
		if i == index:
			slots[i].button_pressed = true
			if slots[i].has_method("grab_focus"):
				slots[i].grab_focus() 
		else:
			slots[i].button_pressed = false

	# Player Logic: Equip the item
	if player and player.has_method("equip_item"):
		player.equip_item(index)
	print("Equipped Slot: ", index + 1)

func deselect_all() -> void:
	current_slot_index = -1
	
	# Visuals: Unpress ALL buttons
	for slot in slots:
		slot.button_pressed = false
		# We usually release focus so the outline goes away too
		if slot.has_focus():
			slot.release_focus()

	# Player Logic: Unequip (Pass -1 or call a specific function)
	if player:
		if player.has_method("unequip_item"):
			player.unequip_item()
		elif player.has_method("equip_item"):
			# A common trick is to pass -1 to say "nothing"
			player.equip_item(-1)
	
	print("Unequipped everything")

# --- Existing Helper Functions ---
func updatePlayer(next_player):
	player = next_player
	# Re-connect health signals if needed
	if player and player.status:
		if not player.status.health_changed.is_connected(updateHealth):
			player.status.health_changed.connect(updateHealth)
		if not player.status.inventory_updated.is_connected(update_inventory_visuals):
			player.status.inventory_updated.connect(update_inventory_visuals)
		
		# Refresh visuals for new player
		updateHealth(player.status.health)
		update_inventory_visuals()

func updateHealth(health: float):
	health_bar.value = health
	var mapped = 1.0 + (1.0 - (health / 100)) * 2.0
	label.text = str(mapped).pad_decimals(1) + " / 1.0"

func update_inventory_visuals() -> void:
	# 1. SAFETY CHECK:
	# If player is null OR if the player node was deleted (freed), stop here.
	if not is_instance_valid(player):
		return

	# 2. Now it is safe to access player.status
	var inventory_data = player.status.inventory
	
	for i in range(slots.size()):
		if i < inventory_data.size():
			var item = inventory_data[i]
			
			if item != null and "texture" in item and item.texture:
				slots[i].icon = item.texture 
			else:
				slots[i].icon = null

func update_quest_list(text: String) -> void:
	if text == "":
		quest_label.text = "No active tasks in this area."
	else:
		quest_label.text = text

func trigger_victory() -> void:
	if victory_popup:
		victory_popup.show_popup()
