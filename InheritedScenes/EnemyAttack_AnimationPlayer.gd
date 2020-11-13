extends AnimationPlayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug("Before: " + self.get_current_animation())
	self.set_current_animation("goomba_attack")
	print_debug("After: " + self.get_current_animation())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.is_playing():
		get_parent().get_parent().enemy.transform.origin= \
												get_parent().transform.origin
	else:
		if get_parent().transform.origin != \
				 get_parent().get_parent().enemy.transform.origin:
			get_parent().get_parent().enemy.transform.origin= \
												get_parent().transform.origin
