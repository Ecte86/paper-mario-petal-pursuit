extends Label
	
onready var OtherNode = get_node("Path/To/Other/Node")

func _process(delta):
	text = ""
	text += "fps: " + str(Engine.get_frames_per_second())
	text += "other variable: " + str(OtherNode.variable)
