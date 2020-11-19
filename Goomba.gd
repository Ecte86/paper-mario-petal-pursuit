extends RigidBody

# Our H.P.
export (int) var Heart_Points = Globals.EnemyHP.Goomba

# Our initial position when we entered the room.
var originalPos: Vector3

# The ground level (just the Y dimension) - may not be zero if we are standing 
# on a surface higher than the ground
var groundLevel: float

onready var battle_status = Globals.battleStatus
onready var playerTurn = Globals.playerTurn

# Declaration of our Parent
var Parent

# Called when the node enters the scene tree for the first time.
func _ready():
	# Setting the Parent to Our room's root node; the scene we are in.
	Parent = get_parent()
	# This function sets up our location and rotation when this object is first
	# created
	
	# If we're in the BattleArena scene...
	if Parent.name != "Main":
		#... set our initial position to wherever our spawn point is
		originalPos=Parent.get_node("EnemySpawn").global_transform.origin
	else:
		#...if we are in the Main scene, set our initial position to wherever
		#   we currently are
		originalPos=self.global_transform.origin
		
	# Lock our movement unless we plan to move somewhere
	lock(true,true)
	setup()
	
func setup():
	
	groundLevel=Parent.get_child(1).scale.y
	self.set_position(self.get_position().x,groundLevel+(self.scale.y/2),self.get_position().z)
	print_debug(self.transform.origin.y)
	print_debug(groundLevel)

func get_position():
	return self.transform.origin

func set_position(x=self.transform.origin.x,y=self.transform.origin.y,z=self.transform.origin.z):
	self.transform.origin.x=x
	self.transform.origin.y=y
	self.transform.origin.z=z

func set_positionV3(newPos):
	self.transform.origin=newPos

func lock(position: bool, angle: bool):
	# General function that locks/unlocks movement, or rotation, or both.
	
	# Lock/unlock position
	self.axis_lock_linear_x=position
	self.axis_lock_linear_y=position
	self.axis_lock_linear_z=position
	
	# Lock/unlock rotation
	self.axis_lock_angular_x=angle
	self.axis_lock_angular_y=angle
	self.axis_lock_angular_z=angle

func flash():
	# unsure if needed
	self.hide()
	yield(get_tree().create_timer(0.2), "timeout")
	self.show()

### Commented out due to not (at this stage) being required ###
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if Globals.battleStatus==1:
#		if Globals.playerTurn==false:
#			self.axis_lock_linear_x=false
#			self.axis_lock_linear_y=false
#			self.axis_lock_linear_z=false
#
#			self.axis_lock_angular_x=false
#			self.axis_lock_angular_y=false
#			self.axis_lock_angular_z=false

# Receiving damage, and death
func receiveDamage(damage):
	# Subtract damage from H.P.
	self.set_Heart_Points(self.get_Heart_Points()-damage)
	
	# If we have no more HP...
	if self.get_Heart_Points() <= 0:
		# Die. (At some point we need to actually remove the enemy from the 
		# Scene's tree after/before death)
		self.hide()
		# If we are in battle...
#		if Parent.name == "BattleArena":
			# See if we can end battle yet?
#			Parent.emit_signal("endBattle", true)
			# Reset player's position (this may be unnecessary; will need to 
			# check
#			Parent.reachedTarget=true
	
func set_Heart_Points(Heart_Points: int):
	# Set H.P. to given value
	self.Heart_Points=Heart_Points
	
func get_Heart_Points():
	# return H.P. value
	return self.Heart_Points

# Someone collided with us!
func _on_Area_body_entered(body):
	
	# If we are in battle
	if battle_status==true:
		# And its not our turn
		if playerTurn==true:
			# and the colliding object is in the group of "Player"
			if body.is_in_group("Player"):
				# and if its higher than our top edge...
				# (Calculate where our top edge is:)
				var topEdge=self.get_child(0).scale.y
				topEdge = topEdge + get_tree().get_root().get_child(1).getWorldEdge().y

				if body.transform.origin.y >= topEdge:
					# get hurt
					receiveDamage(1)

func _process(delta):
	$CollisionShape/AnimatedSprite3D/Shadow.global_transform.origin.y=groundLevel
	$CollisionShape/AnimatedSprite3D/Shadow.global_transform.origin.x= \
		self.get_position().x
	#$CollisionShape/AnimatedSprite3D/Shadow.global_transform.origin.x= \
	#	self.get_position().z
