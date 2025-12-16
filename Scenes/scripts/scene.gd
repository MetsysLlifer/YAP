extends Node

signal player_changed(player)

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var current_scene: Node2D = $Lobby
@onready var ui: CanvasLayer = $UI
@onready var player : CharacterBody2D
var next_scene

# --- CONFIGURATION ---
# CHANGE THESE NUMBERS to match exactly how many task objects are in your rooms!
var global_max_tasks = {
	"dsa": 5, 
	"networking": 5, 
	"oop": 5
}

# --- TRACKING ---
var task_progress = {"dsa": 0, "networking": 0, "oop": 0}
var task_totals = {"dsa": 0, "networking": 0, "oop": 0}

func _ready() -> void:
	player = current_scene.find_child("Player")
	connect_level_signals(current_scene)
	# Initial update to set correct colors on game start
	update_level_tasks(current_scene)

func connect_level_signals(level_node: Node) -> void:
	var portals_container = level_node.find_child("Portals")
	
	# Update tasks immediately so UI shows correct state
	update_level_tasks(level_node)
	
	if portals_container:
		for portal in portals_container.get_children():
			if not portal.scene_changed.is_connected(handle_scene_change):
				portal.scene_changed.connect(handle_scene_change, CONNECT_DEFERRED)

func handle_scene_change(current_scene_name: String, entry_tag: String):
	var next_scene_name: String = ""
	
	match current_scene_name:
		"lobby":
			match entry_tag:
				"to_oop": next_scene_name = "Rooms/oop"
				"to_dsa": next_scene_name = "Rooms/dsa"
				"to_networking": next_scene_name = "Rooms/networking"
				_: return
		"oop", "dsa", "networking":
			next_scene_name = "Rooms/lobby"
		"playground":
			next_scene_name = "Rooms/Lobby"
		_: return
	
	var scene_resource = load("res://Scenes/" + next_scene_name + ".tscn")
	if scene_resource:
		next_scene = scene_resource.instantiate()
		add_child(next_scene)
		
		var spawn_marker = next_scene.find_child(entry_tag)
		var next_player = next_scene.find_child("Player")
		
		if spawn_marker and next_player:
			if player and is_instance_valid(player):
				next_player.status = player.status
			next_player.global_position = spawn_marker.global_position
			player = next_player
			player_changed.emit(player)
		
		# Note: We update tasks here to get the counts, but the DOOR colors 
		# will be applied to the WRONG scene until the animation finishes.
		update_level_tasks(next_scene)
		
		animation_player.play("fade_in")

# --- TASK LOGIC ---

func update_level_tasks(scene_node: Node) -> void:
	task_totals = {"dsa": 0, "networking": 0, "oop": 0}
	
	var task_container = scene_node.find_child("Tasks")
	if task_container:
		for task in task_container.get_children():
			if task.status and "item_name" in task.status:
				var type = task.status.item_name.to_lower()
				if type in task_totals:
					task_totals[type] += 1
					if not task.task_completed.is_connected(_on_task_completed):
						task.task_completed.connect(_on_task_completed)
	
	refresh_quest_ui()

func _on_task_completed(task_type: String) -> void:
	var type = task_type.to_lower()
	if type in task_progress:
		task_progress[type] += 1
		
	refresh_quest_ui()

# --- DOOR LOGIC ---

func check_room_completion() -> void:
	var portals_container = current_scene.find_child("Portals")
	if not portals_container:
		return

	# SCENARIO A: Inside a Task Room
	if task_totals.values().max() > 0: 
		var room_is_complete = true
		for type in task_totals:
			if task_totals[type] > 0:
				if task_progress[type] < global_max_tasks[type]:
					room_is_complete = false
		
		for portal in portals_container.get_children():
			if portal.has_method("set_portal_status"):
				if not room_is_complete:
					portal.set_portal_status(1) # RED (Locked inside)
				else:
					portal.set_portal_status(0) # WHITE (Open)

	# SCENARIO B: Inside the Lobby
	else:
		for portal in portals_container.get_children():
			if portal.has_method("set_portal_status"):
				var tag = portal.entry_tag.to_lower()
				
				var target_category = ""
				if "networking" in tag: target_category = "networking"
				elif "dsa" in tag: target_category = "dsa"
				elif "oop" in tag: target_category = "oop"
				
				if target_category != "":
					if task_progress[target_category] >= global_max_tasks[target_category]:
						portal.set_portal_status(2) # GREEN (Done & Locked)
					else:
						portal.set_portal_status(0) # WHITE (Open)

func refresh_quest_ui() -> void:
	var display_text = ""
	
	if task_totals["networking"] > 0:
		display_text += "Configuring network: %d/%d\n" % [task_progress["networking"], global_max_tasks["networking"]]
	
	if task_totals["dsa"] > 0:
		display_text += "Data Structure problems: %d/%d\n" % [task_progress["dsa"], global_max_tasks["dsa"]]
		
	if task_totals["oop"] > 0:
		display_text += "Fix Object Oriented bugs: %d/%d\n" % [task_progress["oop"], global_max_tasks["oop"]]
	
	if display_text == "":
		display_text = "Select a room to begin."

	if ui.has_method("update_quest_list"):
		ui.update_quest_list(display_text)
	
	check_room_completion()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"fade_in":
			connect_level_signals(next_scene)
			current_scene.queue_free()
			current_scene = next_scene
			next_scene = null
			
			# --- THE FIX IS HERE ---
			# We must refresh the UI and Doors NOW, because 'current_scene'
			# has just switched to the new Lobby.
			refresh_quest_ui()
			# -----------------------
			
			animation_player.play("fade_out")
