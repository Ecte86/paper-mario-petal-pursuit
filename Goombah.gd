extends RigidBody

var hp: int


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
<<<<<<< Updated upstream
	pass # Replace with function body.
=======
	if get_parent().name != "Main":
		originalPos=get_node("../EnemySpawn").transform.origin
		self.rotate_x(90)
>>>>>>> Stashed changes


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.battleStatus==1:
		if Globals.playerTurn==true:
<<<<<<< Updated upstream
			self.mode = 3
		else:
			self.mode = 1
=======
			self.transform.origin=originalPos
	if self.visible==false:
		self.show()
		
func _process(delta):
	#if Globals.battleStatus==1:
		#if Globals.playerTurn==true:
			#self.mode = 3
		#else:
			#self.mode = 1
>>>>>>> Stashed changes
		#Attack goes here?
	#else:
		#self.mode=1
		
#	pass

func receiveDamage(damage):
	self.set_hp(self.get_hp()-damage)
	if self.get_hp() == 0:
		self.hide()
		get_parent().emit_signal("endBattle", true)
	get_parent().reachedTarget=true
	
func set_hp(hp: int):
	self.hp=hp
	
func get_hp():
	return self.hp



func _on_Area_body_entered(body):
	var topEdge=self.get_child(0).scale.y
	topEdge = topEdge + get_parent().getWorldEdge().y
	if Globals.battleStatus==1:
		if Globals.playerTurn==true:
			if get_parent().startedAttack==1:
				if body.is_in_group("Player"):
					if body.transform.origin.y >= topEdge:
						receiveDamage(1)
