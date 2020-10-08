extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.visible==true:
		get_parent().set_process(false)
		$ItemList.select(0, true)
		if Input.is_action_pressed("ui_accept"):
			var test = $ItemList.get_selected_items()
			var stringVar=str($ItemList.get_selected_items()[0])
			get_parent().response=stringVar
			get_parent().set_process(true)
		if Input.is_action_pressed("ui_down"):
			$ItemList.select(0)
	pass
