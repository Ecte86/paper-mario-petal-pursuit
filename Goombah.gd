extends RigidBody

var hp: int
signal endBattle(playerWins)


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var originalPos


# Called when the node enters the scene tree for the first time.
func _ready():
	originalPos=transform.origin
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Globals.battleStatus==1:
		if Globals.playerTurn==true:
			self.transform.origin=originalPos
		
func _process(delta):
	#if Globals.battleStatus==1:
		#if Globals.playerTurn==true:
			#self.mode = 3
		#else:
			#self.mode = 1
		#Attack goes here?
	#else:
		#self.mode=1
		
	pass

func receiveDamage(damage):
	self.set_hp(self.get_hp()-1)
	if self.get_hp() == 0:
		self.hide()
		emit_signal("endBattle", true)
	
func set_hp(hp: int):
	self.hp=hp
	
func get_hp():
	return self.hp
