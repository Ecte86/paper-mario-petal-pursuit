extends RigidBody

export (int) var hp = 2

var originalPos

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug(str(get_parent().name))
	if get_parent().name!="Main":
		originalPos=get_parent().get_node("EnemySpawn").global_transform.origin
		self.rotate_x(90)
		self.rotate_y(0)
		self.rotate_z(0)
	else:
		originalPos=self.global_transform.origin
	self.axis_lock_linear_x=true
	self.axis_lock_linear_y=true
	self.axis_lock_linear_z=true
	
	self.axis_lock_angular_x=true
	self.axis_lock_angular_y=true
	self.axis_lock_angular_z=true	
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.battleStatus==1:
		if Globals.playerTurn==false:
			self.axis_lock_linear_x=false
			self.axis_lock_linear_y=false
			self.axis_lock_linear_z=false
		
			self.axis_lock_angular_x=false
			self.axis_lock_angular_y=false
			self.axis_lock_angular_z=false
#			self.transform.origin=originalPos
#	else:
#		self.transform.origin=originalPos
#		if self.visible==false:
#			self.show()
		
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
	topEdge = topEdge + get_tree().get_root().get_child(1).getWorldEdge().y
	if Globals.battleStatus==1:
		if Globals.playerTurn==true:
			#if get_parent().startedAttack==1:
			if body.is_in_group("Player"):
				if body.transform.origin.y >= topEdge:
					receiveDamage(1)
