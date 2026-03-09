extends Area2D

# This sends the name (e.g., "networking") to the SceneSwitcher
signal task_completed(task_type: String)

@export var status: Task

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var timer: Timer = %Timer # This will be our cooldown timer

var is_player_in_area: bool = false
var can_increment: bool = true # Controls if the progress bar can be increased

# --- Initialization ---

func _ready() -> void:
	sprite_2d.texture = status.get_texture()
	# Connect the signals to detect when a body enters and exits
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	
	# Connect the Timer's timeout signal to reset the can_increment flag
	timer.connect("timeout", _on_timer_timeout)

# --- Signal Handlers ---

func _on_body_entered(body: Node) -> void:
	# Check if the body entering is the player
	if body.is_in_group("player"):
		is_player_in_area = true

func _on_body_exited(body: Node) -> void:
	# Check if the body exiting is the player
	if body.is_in_group("player"):
		# The player left, stop the process and reset progress/timer
		is_player_in_area = false
		timer.stop() # Stop the cooldown timer immediately
		can_increment = true # Reset the increment flag
		
		# OPTIONAL: You might want to reset the progress bar value if the player leaves
		# progress_bar.value = 0 


func _on_timer_timeout() -> void:
	# The cooldown is over, allow incrementing again
	can_increment = true

# --- Main Logic Loop ---

# Use a process function to check the state every frame
func _process(_delta: float) -> void:
	if is_player_in_area and can_increment:
		activate()

# --- Activation Function ---

func activate() -> void:
	# 1. Stop further increments until the cooldown is done
	can_increment = false
	
	# 2. Increment the progress
	progress_bar.value += 100
	
	# 3. Check for completion
	if progress_bar.value >= progress_bar.max_value:
		complete()
	else:
		# 4. Start the cooldown timer
		timer.start()

# --- Completion Function ---

func complete() -> void:
	print("Progress Complete!")
	
	# 2. EMIT SIGNAL BEFORE DELETING
	# We assume 'status' has a variable named 'item_name' (e.g. "networking")
	if status and "item_name" in status:
		emit_signal("task_completed", status.item_name)
	
	queue_free()
