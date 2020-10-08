extends KinematicBody
signal hit

var speed = 300
var direction = Vector3()
var gravity = -9.8
var velocity = Vector3()
var jumpAmount = 10

var onceOnly=1

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

var SceneRoot
var groundLevel

export (NodePath) var attack_path
var attackPath_points
var attackPath_index = 0

var collision_partner

var position: Vector3


func _ready():
	self.set_position(self.position.x,1,self.position.z)
	setHeartPoints(max_Heart_Points)
	if attack_path:
		velocity=Vector3.ZERO
		attackPath_points = get_node(attack_path).curve.get_baked_points()
	SceneRoot=get_tree().get_root().get_child(1)
	self.move_and_slide_with_snap(Vector3(0,5,0),Vector3.DOWN,Vector3.UP)
	#if self.position.y<=0:
	#	self.move_and_slide_with_snap(Vector3(0,5,0),Vector3.DOWN,Vector3.UP)
		#$Shadow.translate(Vector3(0,-1,0))
	self.move_and_slide_with_snap(Vector3(0,-5,0),Vector3.DOWN,Vector3.UP)
	groundLevel=self.transform.origin.y-self.scale.y

func get_position():
	return self.transform.origin

func set_position(x=self.transform.origin.x,y=self.transform.origin.y,z=self.transform.origin.z):
	self.transform.origin.x=x
	self.transform.origin.y=y
	self.transform.origin.z=z
	

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

func setLevel(num: int):
	Level=num

func setPetalPower(num: int):
	Petal_Power=num

func setCoins(num: int):
	Coins=num

func setHeartPoints(num: int):
	self.Heart_Points=num
	#Globals.hp=num
	
func getHeartPoints():
	return self.Heart_Points

func _process(delta):

	# Animation processing!
	
	var mario_direction # Possible values: N, S, E, W, NW, SW, NE, SE and Idle

	if direction.z==0 and direction.x==0:
		mario_direction="Idle"
	if direction.z<0 and direction.x<0:
		mario_direction="NW"
	if direction.z>0 and direction.x<0:
		mario_direction="SW"
	if direction.z>0 and direction.x>0:
		mario_direction="SE"
	if direction.z<0 and direction.x>0:
		mario_direction="NE"
		
	if direction.z<0 and direction.x==0:
		mario_direction="N"
	if direction.z>0 and direction.x==0:
		mario_direction="S"
	if direction.z==0 and direction.x>0:
		mario_direction="E"
	if direction.z==0 and direction.x<0:
		mario_direction="W"
		
	#$AnimatedSprite3D.flip_h=false
	match mario_direction:
		"Idle":
			$AnimatedSprite3D.play("idleDown")
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
			
	if !is_on_floor() and self.transform.origin.y>groundLevel: # If mario is in the air, jump
		$AnimatedSprite3D.play("jump")
		if direction.x>0: # flip if we are heading right
			$AnimatedSprite3D.flip_h=true
		else:
			if is_on_floor() or direction.x<0: #head left only if user specifies, or we complete jump
				$AnimatedSprite3D.flip_h=false
	$AnimatedSprite3D/Shadow.global_transform.origin.y=groundLevel
	
	
	
	

	#if Input.is_action_just_released("ui_up"):
		#$AnimatedSprite3D.play("idleUp")

func attack(delta):
	var target = get_parent().getEnemy().transform.origin #attackPath_points[attackPath_index-1]
	var position = self.transform.origin
	if position.distance_to(target) < 4.5:
		if reachedTarget==0:
			reachedTarget=1
			if onceOnly == 1:
				onceOnly = 0
				velocity.x=1*speed*delta
				velocity.y=jumpAmount
			else:
				velocity.x = 0
	else:
		if reachedTarget == 0:
			velocity = (target - position).normalized() * speed * delta
	#if attackPath_index < attackPath_points.size():
	#	attackPath_index=attackPath_index+1
	#else:
	#	if onceOnly == 1:
	#		onceOnly=0
			
	#	else:
	#		velocity.x=0
			
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var edge=get_parent().getWorldEdge()
	var EdgeLocationsX=[-edge.x,edge.x]
	var EdgeLocationsZ=[-edge.z,edge.z]
	if self.global_transform.origin.y<0:
		print_debug( "wtf:"+str(self.global_transform.origin))
	self.global_transform.origin.x = clamp(self.global_transform.origin.x,-edge.x,edge.x)
	self.global_transform.origin.z = clamp(self.global_transform.origin.z,-(edge.z)/2,edge.z/2)
	var gravity_modified = gravity * 1.5
	if attack_path:
		if Globals.battleStatus==1:
			if Globals.playerTurn==true:
				
				direction.x=velocity.x
				#direction.z=velocity.z
				velocity.y += gravity_modified*delta
				velocity = move_and_slide(velocity, Vector3(0,1,0))
				
	else:
		if Globals.battleStatus==0:
			direction=Vector3(0,0,0)
			if Input.is_action_pressed("ui_left"):
				direction.x -= 1 # subtract 1 from direction.x
			if Input.is_action_pressed("ui_right"):
				direction.x += 1 # add 1 from direction.x
				#$AnimationPlayer.play("Walk Down")
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
		
			if Input.is_action_pressed("jump"): # TODO: find a better action for jumping
				#velocity.y=10
				if is_on_floor():
					velocity.y=jumpAmount
	

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
			if self.is_on_floor():
				self.setHeartPoints(self.getHeartPoints()-1)
			else:
				#self.get_parent().enemy.receiveDamage(1)
				get_parent().reachedTarget=1
				self.velocity.x=0
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

