extends AnimationPlayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var SceneRoot = get_parent().get_parent()
onready var enemy = SceneRoot.enemy

# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug("Before: " + self.get_current_animation())
	self.set_current_animation("goomba_attack")
	self.seek(0,true)
	print_debug("After: " + self.get_current_animation())
	self.get_animation(self.current_animation).loop = false
	
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.is_playing():
		SceneRoot.enemy.lock(false,false)
		SceneRoot.enemy.set_rotation(Vector3(-1*delta,0,0),true)
		SceneRoot.enemy.set_positionV3(get_parent().global_transform.origin)
		### TODO: *make Goomba inherit from Spatial or MeshInstance? ###
	else:
		SceneRoot.enemy.lock(true,true)
