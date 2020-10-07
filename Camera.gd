extends Camera


# Scroll the screen (aka. move the camera) when the character reaches the margins.
var drag_margin_left = 0
var drag_margin_right = 0.4

# The left/right most edge of the scene. (The camera couldn't move past these limits.)
var right_limit = 10
var left_limit = -10
var top_limit = 0
var bottom_limit = 0

# Screen size.
var screen_size

onready var root = get_tree().get_root()

# Being called when loaded.
func _ready():
	screen_size = root.get_viewport().get_visible_rect().size

# Actually scroll the screen (update the viewport according to the position of the camera).
#func update_viewport():
	#var canvas_transform = root.get_viewport().get_canvas_transform()
	#canvas_transform.o = -root.transform.origin + screen_size / 2.0
	#self.translate()

# This function should be called whenever the character moves.
func update_camera(character_pos):
	var new_camera_pos = self.transform.origin

	# Check if the character reaches the right margin.
	if character_pos.x > self.transform.origin.x + screen_size.x * (drag_margin_right - 0.5):
		new_camera_pos.x = character_pos.x - screen_size.x * (drag_margin_right - 0.5)
	
	# Check if the character reaches the left margin.
	elif character_pos.x < self.transform.origin.x + screen_size.x * (drag_margin_left - 0.5):
		# Character reaches the left drag margin.
		new_camera_pos.x = character_pos.x + screen_size.x * (0.5 - drag_margin_left)

	# Clamp the new camera position within the limits.
	new_camera_pos.x = clamp(new_camera_pos.x, left_limit + screen_size.x * 0.5, right_limit - screen_size.x * 0.5)
	new_camera_pos.y = clamp(new_camera_pos.y, top_limit + screen_size.y * 0.5, bottom_limit - screen_size.y * 0.5)
	
	# Actually update the position of the camera.
	self.global_translate(new_camera_pos)
	#update_viewport()
	pass

func _process(delta):
	var charPos = root.get_child(1).player
	if charPos == null:
		print_debug("Hmm.")
		print_tree_pretty()
		breakpoint
	else:
		self.update_camera(charPos.transform.origin)
