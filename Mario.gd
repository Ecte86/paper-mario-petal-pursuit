extends KinematicBody
class_name Mario
signal hit

var speed = 550
var direction = Vector3()
var gravity = -45
var velocity = Vector3()
var jumpAmount = 20

enum states {
	IDLE = 0
	NW = 1
	SW = 2
	SE = 3
	NE = 4
	N = 5
	S = 6
	E = 7
	W = 8
	JUMP = 9
	IGNORE = 99
}

var doubleAttack = false

var state = states.IDLE

var onceOnly=1

var idleTime=0

var idleAnimTime=0

export (int) var idleStatsBar=10

export (int) var idleSeconds = 3

export (int) var fps=60 #not sure if 60

var reachedTarget=0

export(int) var Heart_Points = 10 # Heart Points == Hit Points == Life
export(int) var max_Heart_Points = 10 # Maximum Heart Points == Hit Points == Life

export (int) var Flower_Points = 10 # FP = Mana
export (int) var max_Flower_Points = 10 # Max FP = Mana

export (int) var Badge_Points = 0 # Points to use for "Equipment" I guess
export (int) var max_Badge_Points = 10 # 

export (int) var Star_Points = 0 # XP
export (int) var max_Star_Points = 99 # XP

export (int) var Level = 1
export (int) var max_Level = 10

export (int) var Petal_Power = 0
export (int) var max_Petal_Power = 7

export (int) var Coins = 100
export (int) var max_Coins = 100

var sMarioDirection: String

var SceneRoot
var groundLevel

export (NodePath) var attack_path
var attackPath_points
var attackPath_index = 0

var collision_partner

var position: Vector3

var bfacingAway: bool = false
var bMarioJumping: bool = false

onready var battle_status = Globals.battleStatus

enum Stat_idx{
	NAME = 0,
	HEART_POINTS = 1,
	FLOWER_POINTS = 2,
	BADGE_POINTS = 3,
	STAR_POINTS = 4,
	LEVEL = 5,
	PETAL_POWER = 6,
	COINS = 7
}


func _ready():
	setup()
	
func setup():
	#self.set_position(self.position.x,1,self.position.z)
	SceneRoot=get_parent()
	#self.move_and_slide_with_snap(Vector3(0,5,0),Vector3.DOWN,Vector3.UP)
	#self.move_and_slide_with_snap(Vector3(0,-5,0),Vector3.DOWN,Vector3.UP)
	groundLevel=self.transform.origin.y-self.scale.y
	#self.set_position(self.position.x,0.1,self.position.z)
	print_debug(str(self.get_position()))
	print_debug("GL: " + str(groundLevel))
	$AnimatedSprite3D.play("idleDown")
	

func get_position():
	return self.transform.origin

func checkforAttackInput() -> bool:
	#if SceneRoot.time_limited_input_check:
	if Input.is_action_pressed("jump"): # Spacebar on PC, A on Nintendo
		return true
	else:
		return false
	#else:
	#	return false

func set_position(x=self.transform.origin.x,y=self.transform.origin.y,z=self.transform.origin.z):
	self.transform.origin.x=x
	self.transform.origin.y=y
	self.transform.origin.z=z

func hflip(dir: bool):
	$AnimatedSprite3D.flip_h=dir

func set_positionV3(newPos):
	self.transform.origin=newPos

func new_game():
	setHeartPoints(max_Heart_Points)
	
func getFlowerPoints():
	return Flower_Points

func getBadgePoints(): # Points to use for "Equipment" I guess
	return Badge_Points

func getStarPoints(): # XP
	return Star_Points

func getLevel():
	return Level

func getPetalPower():
	return Petal_Power

func getCoins():
	return Coins

func setFlowerPoints(num: int):
	Flower_Points = num

func setBadgePoints(num: int): # Points to use for "Equipment" I guess
	Badge_Points = num

func setStarPoints(num: int): # XP
	Star_Points=num
	if Star_Points>Globals.max_Star_Points:
		Star_Points=Star_Points-Globals.max_Star_Points
		self.setLevel(self.getLevel()+1)

func setLevel(num: int):
	Level=num
	if Level>=Globals.max_Level:
		Level=Globals.max_Level
		self.setStarPoints(Globals.max_Star_Points)

func setPetalPower(num: int):
	Petal_Power=num

func setCoins(num: int):
	Coins=num

func setHeartPoints(num: int):
	self.Heart_Points=num
	if self.Heart_Points<1:
		get_parent().emit_signal("endBattle",false)
	#Globals.hp=num
	
func getHeartPoints():
	return self.Heart_Points

func _process(_delta):

	if get_parent().name=="Globals":
		return
	# Animation processing!
	
	# sMarioDirection - Possible values: N, S, E, W, NW, SW, NE, SE and Idle
	
	var sCurrentMarioDirection: String = ""
	
	#$AnimatedSprite3D.flip_h=false
	if (!is_on_floor() and \
			 self.transform.origin.y>groundLevel and \
			 SceneRoot.name!="BattleArena") \
			 or state == states.JUMP: # If mario is in the air, jump
		state=states.JUMP
		if bfacingAway==false:
			$AnimatedSprite3D.play("jump") # (set animation to "jump")
		else:
			$AnimatedSprite3D.play("upJump")
		return
	else:
		state=states.IDLE

	if direction.z==0 and direction.x==0 or state == states.IDLE:
		sMarioDirection="Idle"
	if direction.z<0 and direction.x<0 or state == states.NW:
		sMarioDirection="NW"
	if direction.z>0 and direction.x<0 or state == states.SW:
		sMarioDirection="SW"
	if direction.z>0 and direction.x>0 or state == states.SE:
		sMarioDirection="SE"
	if direction.z<0 and direction.x>0 or state == states.NE:
		sMarioDirection="NE"
		
	if direction.z<0 and direction.x==0 or state == states.N:
		sMarioDirection="N"
	if direction.z>0 and direction.x==0 or state == states.S:
		sMarioDirection="S"
	if direction.z==0 and direction.x>0 or state == states.E:
		sMarioDirection="E"
	if direction.z==0 and direction.x<0 or state == states.W:
		sMarioDirection="W"		
	
	bMarioJumping=false
#	if sMarioDirection==sCurrentMarioDirection:
#		return
#	else:
#		sCurrentMarioDirection = sMarioDirection
	match sMarioDirection:
		"Idle":
			if bfacingAway==false:
				$AnimatedSprite3D.play("idleDown")
			else:
				$AnimatedSprite3D.play("idleUp")
			
		"NW":
			$AnimatedSprite3D.play("walkUp")
			$AnimatedSprite3D.flip_h=false
		"NE":
			$AnimatedSprite3D.play("walkUp")
			$AnimatedSprite3D.flip_h=true
		"SW":
			$AnimatedSprite3D.play("walkDown")
			$AnimatedSprite3D.flip_h=false
		"SE":
			$AnimatedSprite3D.play("walkDown")
			$AnimatedSprite3D.flip_h=true
		"N":
			$AnimatedSprite3D.play("walkUp")
			#$AnimatedSprite3D.flip_h=false
		"S":
			$AnimatedSprite3D.play("walkDown")
			#$AnimatedSprite3D.flip_h=false
		"W":
			$AnimatedSprite3D.play("walkDown")
			$AnimatedSprite3D.flip_h=false
		"E":
			$AnimatedSprite3D.play("walkDown")
			$AnimatedSprite3D.flip_h=true
			
	if $AnimatedSprite3D.animation == "walkUp":
		bfacingAway=true
	elif $AnimatedSprite3D.animation == "walkDown":
		bfacingAway=false
			
		if direction.x>0: # flip if we are heading right
			$AnimatedSprite3D.flip_h=true
		else:
			if is_on_floor() or direction.x<0: #head left only if user specifies, or we complete jump
				$AnimatedSprite3D.flip_h=false
		
	if Globals.FAKE_SHADOW:
		$AnimatedSprite3D/Shadow.show()
		$AnimatedSprite3D/Shadow.global_transform.origin.y=groundLevel
	else:
		$AnimatedSprite3D/Shadow.hide()

#	I cannot get this to work very well.
#	if sMarioDirection=="Idle":
#		yield(get_tree().create_timer(10), "timeout")
#		get_parent().showGUI(3,true)
#	else:
#		get_parent().hideGUI()

	
	
	
	

	#if Input.is_action_just_released("ui_up"):
		#$AnimatedSprite3D.play("idleUp")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if get_parent().name=="Globals":
		return
	
	var edge=get_parent().getWorldEdge()
	#var EdgeLocationsX=[-edge.x,edge.x]
	#var EdgeLocationsZ=[-edge.z,edge.z]
	self.global_transform.origin.x = clamp(self.global_transform.origin.x,-edge.x,edge.x)
	self.global_transform.origin.z = clamp(self.global_transform.origin.z,-(edge.z)/2,edge.z/2)
	var gravity_modified = gravity * 1.5
	if attack_path:
		if Globals.battleStatus==true:
			if Globals.playerTurn==true:
				direction.x=velocity.x
				velocity.y += gravity_modified*delta
				velocity = move_and_slide(velocity, Vector3(0,1,0))
	else:
		if Globals.battleStatus==false:
			direction=Vector3(0,0,0)
			if Input.is_action_pressed("ui_left"):
				direction.x -= 1 # subtract 1 from direction.x
			if Input.is_action_pressed("ui_right"):
				direction.x += 1 # add 1 from direction.x
			if Input.is_action_pressed("ui_down"):
				direction.z += 1 # add 1 from direction.z
			if Input.is_action_pressed("ui_up"):
				direction.z -= 1 # subtract 1 from direction.z
			direction=direction.normalized()
			direction=direction*speed*delta
			
			
			velocity.y += gravity_modified*delta
			velocity.x=direction.x
			velocity.z=direction.z
			
			velocity = move_and_slide(velocity,Vector3(0,1,0))
		
			if Input.is_action_just_pressed("jump"): # TODO: find a better action for jumping?
				#velocity.y=10
				if is_on_floor():
					velocity.y=jumpAmount
					self.play("jump")
					

func play(soundName: String):
	if soundName=="jump":
		$AnimatedSprite3D/AudioStreamPlayer.play() # (play "jump" sound)

	#velocity = move_and_slide(direction,Vector3(0,1,0))

#	pass

func set_last_collision_partner(body):
	collision_partner = body

func get_last_collision_partner():
	return collision_partner

func isOnFloor():
	return (velocity.y > 0)

func _on_Area_body_entered(body):
	set_last_collision_partner(body)
	if body.is_in_group("Enemies"):
		if get_parent().name=="BattleArena":#if Globals.battleStatus==1:
			if Globals.playerTurn==true:
				#if self.is_on_floor():
				get_parent().emit_signal("mario_hit")
			else:
				get_parent().emit_signal("stop_enemy_attack")
				self.setHeartPoints(self.getHeartPoints()-1)
		else:
			if self.is_on_floor():
				get_parent().emit_signal("main_startBattle",false)
			else:
				get_parent().emit_signal("main_startBattle",true)
	#else:
		#print_debug(body.group)
			#yield(get_parent(), "main_startBattle")
			#yield(get_parent(),"main_startBattle(true)")

	#if body is RigidBody:#Area: # TODO: What type will enemy be? Assuming area for now.
	#	body.hide() # eliminate enemy as a test
