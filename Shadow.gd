extends Sprite3D

export (NodePath) var myOwnerPath = null

var myOwner = null

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if myOwner==null:
		if myOwnerPath!=null:
			myOwner=get_node(myOwnerPath)
			setupPosition(myOwner.transform.origin)
		else:
			self.hide()
	else:
		setupPosition(myOwner.transform.origin)

func setupPosition(position: Vector3):
	print_debug(get_tree().get_root().get_child(1).name)
	self.transform.origin.x=position.x
	self.transform.origin.y=get_tree().get_root().get_child(1).find_node("Floor").get_child(0).scale.y+0.1
	self.transform.origin.z=position.z
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
