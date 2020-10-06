extends ItemList


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent().visible:
		self.select(0)
		 # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		var test = self.get_selected_items()
		get_parent().get_parent().response=self.get_item_text(self.get_selected_items()[0])
		get_parent().hide()
	if Input.is_action_pressed("ui_down"):
		self.select(0)
#	pass
