extends Node

signal player_changed(player)

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var current_scene: Node2D = $Lobby
@onready var ui: CanvasLayer = $UI
@onready var player : CharacterBody2D
var next_scene

# --- CONFIGURATION ---
# Requirements to UNLOCK the Boss Room from the Lobby
var global_requirements = {
	"dsa": 5, 
	"networking": 5, 
	"oop": 5
}

# --- TRACKING ---
var global_progress = {"dsa": 0, "networking": 0, "oop": 0}
var local_totals = {}
var local_progress = {}

func _ready() -> void:
	player = current_scene.find_child("Player")
	connect_level_signals(current_scene)
	update_level_tasks(current_scene)

func connect_level_signals(level_node: Node) -> void:
	var portals_container = level_node.find_child("Portals")
	
	update_level_tasks(level_node)
	
	if portals_container:
		for portal in portals_container.get_children():
			if not portal.scene_changed.is_connected(handle_scene_change):
				portal.scene_changed.connect(handle_scene_change, CONNECT_DEFERRED)

# --- SCENE SWITCHING (WITH "VOID" FIX) ---

func handle_scene_change(current_scene_name: String, entry_tag: String):
	# 1. FREEZE OLD SCENE (Don't hide yet to prevent flickering)
	if current_scene:
		current_scene.process_mode = Node.PROCESS_MODE_DISABLED
	
	# 2. FADE TO BLACK
	animation_player.play("fade_in")
	await animation_player.animation_finished
	
	# 3. LOAD NEXT SCENE
	var next_scene_name: String = ""
	
	match current_scene_name:
		"lobby":
			match entry_tag:
				"to_oop": next_scene_name = "Rooms/oop"
				"to_dsa": next_scene_name = "Rooms/dsa"
				"to_networking": next_scene_name = "Rooms/networking"
				"to_boss": next_scene_name = "Rooms/boss"
				_: return
		"oop", "dsa", "networking", "boss":
			next_scene_name = "Rooms/lobby"
		"playground":
			next_scene_name = "Rooms/Lobby"
		_: return
	
	var scene_resource = load("res://Scenes/" + next_scene_name + ".tscn")
	if scene_resource:
		next_scene = scene_resource.instantiate()
		add_child(next_scene)
		
		# Position Player
		var spawn_marker = next_scene.find_child(entry_tag)
		var next_player = next_scene.find_child("Player")
		
		if spawn_marker and next_player:
			if player and is_instance_valid(player):
				next_player.status = player.status
			next_player.global_position = spawn_marker.global_position
			player = next_player
			player_changed.emit(player)
		
		# Setup Logic
		connect_level_signals(next_scene)
		update_level_tasks(next_scene)
		
		# Remove Old Scene
		current_scene.queue_free()
		current_scene = next_scene
		next_scene = null
		
		# Refresh UI to ensure text is correct
		refresh_quest_ui()
		
		# 4. FADE IN NEW SCENE
		animation_player.play("fade_out")
	else:
		print("Error: Could not load scene: " + next_scene_name)
		current_scene.process_mode = Node.PROCESS_MODE_INHERIT
		animation_player.play("fade_out")

# --- TASK LOGIC ---

func update_level_tasks(scene_node: Node) -> void:
	# ... existing reset code ...
	local_totals = {}
	local_progress = {}
	
	var task_container = scene_node.find_child("Tasks")
	if task_container:
		for task in task_container.get_children():
			if task.status and "item_name" in task.status:
				var type = task.status.item_name.to_lower()
				
				# --- ADD THIS DEBUG PRINT ---
				print("Found Task: ", task.name, " | Type: ", type)
				# ----------------------------
				
				if not type in local_totals:
					local_totals[type] = 0
					local_progress[type] = 0
				
				local_totals[type] += 1
				
				if not task.task_completed.is_connected(_on_task_completed):
					task.task_completed.connect(_on_task_completed)
	
	refresh_quest_ui()

func _on_task_completed(task_type: String) -> void:
	var type = task_type.to_lower()
	
	# Update Local Count (For UI)
	if type in local_progress:
		local_progress[type] += 1
	
	# Update Global Count (Only if NOT in boss room, to preserve lobby logic)
	if current_scene.name.to_lower() != "boss":
		if not type in global_progress: global_progress[type] = 0
		global_progress[type] += 1
		
	refresh_quest_ui()

# --- DOOR LOGIC ---

func check_room_completion() -> void:
	var portals_container = current_scene.find_child("Portals")
	if not portals_container:
		return

	# SCENARIO A: Inside Task Room (Any room with tasks)
	if local_totals.size() > 0: 
		var room_is_complete = true
		for type in local_totals:
			if local_progress[type] < local_totals[type]:
				room_is_complete = false
				break
		
		for portal in portals_container.get_children():
			if portal.has_method("set_portal_status"):
				if not room_is_complete:
					portal.set_portal_status(1) # RED (Locked)
				else:
					portal.set_portal_status(0) # WHITE (Open)

	# SCENARIO B: Inside Lobby
	else:
		for portal in portals_container.get_children():
			if portal.has_method("set_portal_status"):
				var tag = portal.entry_tag.to_lower()
				
				if "boss" in tag:
					if is_global_qualified("dsa") and is_global_qualified("networking") and is_global_qualified("oop"):
						portal.set_portal_status(0) 
					else:
						portal.set_portal_status(1)
				else:
					var category = ""
					if "networking" in tag: category = "networking"
					elif "dsa" in tag: category = "dsa"
					elif "oop" in tag: category = "oop"
					
					if category != "":
						if is_global_qualified(category):
							portal.set_portal_status(2) # GREEN
						else:
							portal.set_portal_status(0) # WHITE

func is_global_qualified(category: String) -> bool:
	return global_progress.get(category, 0) >= global_requirements.get(category, 5)

func refresh_quest_ui() -> void:
	var display_text = ""
	
	# If we are in a room with tasks (Main Rooms OR Boss Room)
	if local_totals.size() > 0:
		# Force a nice order for the display
		var order_list = ["dsa", "networking", "oop"]
		
		# Add any other types found that aren't in the standard list
		for t in local_totals.keys():
			if not t in order_list:
				order_list.append(t)
		
		# Generate the text line by line
		for type in order_list:
			if type in local_totals:
				var pretty_name = type.capitalize()
				if type == "dsa": pretty_name = "Data Structures"
				if type == "oop": pretty_name = "Object Oriented"
				if type == "networking": pretty_name = "Networking"
				
				display_text += "%s: %d/%d\n" % [pretty_name, local_progress[type], local_totals[type]]
				
	else:
		# Lobby Text
		if is_global_qualified("dsa") and is_global_qualified("networking") and is_global_qualified("oop"):
			display_text = "FINAL EXAM UNLOCKED!\nEnter the Boss Room."
		else:
			display_text = "Complete all modules to unlock Final Exam."

	if ui.has_method("update_quest_list"):
		ui.update_quest_list(display_text)
	
	check_room_completion()
