extends RigidBody

# Our H.P.
export (int) var Heart_Points = 2

# Our initial position when we entered the room.
var originalPos: Vector3

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Our room's root node; the scene we are in.
var Parent = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	# This function sets up our location and rotation when this object is first
	# created
	
	# If we're in the BattleArena scene...
	if Parent.name!="Main":
		#... set our initial position to wherever our spawn point is
		originalPos=Parent.get_node("EnemySpawn").global_transform.origin
		#...and rotate so we are pointing up.
		self.rotate_x(90)
		self.rotate_y(0)
		self.rotate_z(0)
	else:
		#...if we are in the Main scene, set our initial position to wherever
		#   we currently are
		originalPos=self.global_transform.origin
		
	# Lock our movement unless we plan to move somewhere
	lock(true,true)
	
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
		if Parent.name == "BattleArena":
			# See if we can end battle yet?
			Parent.emit_signal("endBattle", true)
			# Reset player's position (this may be unnecessary; will need to 
			# check
			Parent.reachedTarget=true
	
func set_Heart_Points(Heart_Points: int):
	# Set H.P. to given value
	self.Heart_Points=Heart_Points
	
func get_Heart_Points():
	# return H.P. value
	return self.Heart_Points

# Someone collided with us!
func _on_Area_body_entered(body):
	# Calculate where our top edge is:
	var topEdge=self.get_child(0).scale.y
	topEdge = topEdge + get_tree().get_root().get_child(1).getWorldEdge().y
	
	# If we are in battle
	if Parent.battleStatus==true:
		# And its not our turn
		if Globals.playerTurn==true:
			# and the colliding object is in the group of "Player"
			if body.is_in_group("Player"):
				# and if its higher than our top edge...
				if body.transform.origin.y >= topEdge:
					# get hurt
					receiveDamage(1)
