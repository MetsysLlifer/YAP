extends Panel

# Grab our nodes based on your exact scene tree structure
@onready var page_container = $BG/Control
@onready var next_button = $Next
@onready var prev_button = $Previous

# This will automatically hold [Heal, Enemy, Tasks]
var pages: Array[Node] = []
var current_index: int = 0

func _ready() -> void:
	# 1. Automatically get all the child nodes inside "Control"
	pages = page_container.get_children()
	
	# 2. Connect the buttons to our functions
	next_button.pressed.connect(_on_next_pressed)
	prev_button.pressed.connect(_on_prev_pressed)
	
	# 3. Make sure only the first page is visible when the scene starts
	update_page_visibility()

func _on_next_pressed() -> void:
	current_index += 1
	
	# If the index goes out of bounds (past "Tasks"), loop back to 0 ("Heal")
	if current_index >= pages.size():
		current_index = 0
		
	update_page_visibility()

func _on_prev_pressed() -> void:
	current_index -= 1
	
	# If the index goes below 0 (before "Heal"), loop to the end ("Tasks")
	if current_index < 0:
		current_index = pages.size() - 1
		
	update_page_visibility()

func update_page_visibility() -> void:
	# Loop through all our pages. 
	# If the page's number matches our current_index, show it. Otherwise, hide it.
	for i in range(pages.size()):
		if i == current_index:
			pages[i].visible = true
		else:
			pages[i].visible = false
