extends AnimationPlayer

onready var oMario = get_parent().get_parent().Mario
onready var Parent = get_parent()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug("Before: " + self.get_current_animation())
	self.set_current_animation("run_and_jump_up")
	print_debug("After: " + self.get_current_animation())
	 # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if self.is_playing(): #if we are playing the first anim
		if self.current_animation=="run_and_jump_up":
			get_parent().get_parent().Mario.state= \
				get_parent().get_parent().Mario.states.E
			if self.current_animation_position==0.6: # and we reach the point where Mario "jumps"
				get_parent().get_parent().Mario.play("jump")
		get_parent().get_parent().Mario.transform.origin = Parent.transform.origin
	if self.current_animation=="reset":
		get_parent().get_parent().Mario.transform.origin = Parent.transform.origin
		get_parent().get_parent().Mario.states.IDLE
