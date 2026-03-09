extends Area2D

signal task_completed(task_type: String)

@export var status: Task
@export_range(1, 5) var task_id: int = 1 

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var timer: Timer = %Timer
@onready var slider: HSlider = get_node_or_null("SliderUI")
@onready var bug_ui: Control = get_node_or_null("BugUI")
@onready var sequence_label: Label = $SequenceUI
@onready var task_action: AnimationPlayer = %TaskAction
@onready var impact: Sprite2D = $Impact

var is_player_in_area: bool = false
var sequence_progress: int = 0
# CHANGED TO UCKL FOR EXHIBIT
var target_sequence: Array = ["U", "C", "K", "L"]
var last_key: String = "" 

func _ready() -> void:
	impact.visible = false
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	if status:
		sprite_2d.texture = status.get_texture()
	_hide_all_ui()

func _process(delta: float) -> void:
	if not is_player_in_area: return

	match task_id:
		1: # THE LOADING BAR
			sequence_label.visible = true
			sequence_label.text = "SMASH SPACE TO COMPILE!"
			if Input.is_action_just_pressed("ui_accept"):
				progress_bar.value += 10
				task_action.play("success")
		2: # THE FOCUS TEST
			if slider:
				slider.visible = true
				sequence_label.visible = true
				sequence_label.text = "PRESS SPACE IN THE GREEN!"
				slider.value = pingpong(Time.get_ticks_msec() * 0.1, 100)
				if Input.is_action_just_pressed("interact"): 
					if slider.value > 40 and slider.value < 60:
						progress_bar.value += 35
						task_action.play("success")
					else:
						progress_bar.value -= 5
		3: # THE SYNTAX BUFFER
			if slider and sequence_label:
				slider.visible = true
				sequence_label.visible = true
				slider.max_value = 10 
				if Input.is_action_just_pressed("move_left"):
					if last_key != "left":
						slider.value += 1
						task_action.play("success")
						last_key = "left"
						sequence_label.text = "BUFFER: [ > ]"
					else:
						slider.value = 0 
						sequence_label.text = "SYNTAX ERROR!"
				if Input.is_action_just_pressed("move_right"):
					if last_key != "right":
						slider.value += 1
						task_action.play("success")
						last_key = "right"
						sequence_label.text = "BUFFER: [ < ]"
					else:
						slider.value = 0
						sequence_label.text = "SYNTAX ERROR!"
				if slider.value >= slider.max_value:
					progress_bar.value += 25
					slider.value = 0
					sequence_label.text = "LINE PROCESSED!"
		4: # THE CODE SEQUENCE (UCKL)
			if sequence_label:
				sequence_label.visible = true
				var display_text = "INPUT: "
				var i = sequence_progress
				while i < target_sequence.size():
					display_text += str(target_sequence[i])
					i += 1
				sequence_label.text = display_text
				_handle_sequence_input()
		5: # THE UPLOAD
			sequence_label.visible = true
			sequence_label.text = "UPLOADING... STAY CLOSE!"
			progress_bar.value += 15 * delta
			task_action.play("success")

	if progress_bar.value >= progress_bar.max_value:
		complete()

func _handle_sequence_input():
	var key = ""
	# Updated to use the non-movement keys
	if Input.is_action_just_pressed("task_u"): key = "U"
	elif Input.is_action_just_pressed("task_c"): key = "C"
	elif Input.is_action_just_pressed("task_k"): key = "K"
	elif Input.is_action_just_pressed("task_l"): key = "L"
	
	if key != "":
		var current_target = str(target_sequence[sequence_progress])
		if key == current_target:
			sequence_progress += 1
			task_action.play("success")
			if sequence_progress >= target_sequence.size():
				progress_bar.value += 50
				sequence_progress = 0 

func complete() -> void:
	if status and "item_name" in status:
		emit_signal("task_completed", status.item_name)
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		is_player_in_area = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		is_player_in_area = false
		_hide_all_ui()

func _hide_all_ui():
	if slider: slider.visible = false
	if bug_ui: bug_ui.visible = false
	if sequence_label: sequence_label.visible = false
