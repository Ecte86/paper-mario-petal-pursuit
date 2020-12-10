extends AnimationPlayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var SceneRoot = get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug("Before: " + self.get_current_animation())
	self.set_current_animation("goomba_attack")
	self.seek(0,true)
	print_debug("After: " + self.get_current_animation())
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.is_playing():
		SceneRoot.enemy.transform.origin = \
												get_parent().transform.origin
		var angle = get_parent().rotation_degrees.z
		SceneRoot.enemy.rotation_degrees.z=angle
	else:
		if get_parent().transform.origin != \
				 SceneRoot.enemy.transform.origin:
			SceneRoot.enemy.transform.origin = \
												get_parent().transform.origin
