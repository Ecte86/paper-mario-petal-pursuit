extends KinematicBody
signal hit

var airspeed = 520
var speed = 505
var friction = 0.5
var acceleration = 40
var deacceleration = 30

var direction = Vector3()
var gravity = -85
var velocity = Vector3()
var jump_height = 25



var hp

export (NodePath) var attack_path
var attackPath_points
var attackPath_index = 0

var collision_partner

func _ready():
	set_hp(Globals.hp)
	if attack_path:
		velocity=Vector3(0,0,0)
		attackPath_points = get_node(attack_path).curve.get_baked_points()

func new_game():
	set_hp(10)
	
func set_hp(num):
	hp=num
	Globals.hp=num
	
func get_hp():
	return Globals.hp

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
			

	if !is_on_floor(): # If mario is in the air, jump
		$AnimatedSprite3D.play("jump")
		if direction.x>0: # flip if we are heading right
			$AnimatedSprite3D.flip_h=true
		else:
			if is_on_floor() or direction.x<0: #head left only if user specifies, or we complete jump
				$AnimatedSprite3D.flip_h=false
	
	
	
	

	#if Input.is_action_just_released("ui_up"):
		#$AnimatedSprite3D.play("idleUp")

func attack(delta):
#	var target = attackPath_points[attackPath_index]
#	var position = self.transform.origin
#	#if position.distance_to(target) < 1:
#	#	attackPath_index = wrapi(attackPath_index + 1, 0, attackPath_points.size())
#	#	target = attackPath_points[attackPath_index]
#	velocity = (target - position).normalized() * speed
#	velocity = move_and_slide(velocity, Vector3(0,1,0))

	velocity = move_and_slide(velocity, Vector3(0,1,0))
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var edge=get_parent().getWorldEdge()
	self.transform.origin.x = clamp(self.transform.origin.x,-edge.x,edge.x)
	self.transform.origin.z = clamp(self.transform.origin.z,-edge.z,edge.z)
	#var gravity_modified = gravity * 1.5
	if attack_path:
		if Globals.battleStatus==1:
			if Globals.playerTurn==true:
				#velocity=get_parent().playerAttack(delta)
				direction.x=velocity.x
				velocity.y += gravity*delta
				move_and_slide(velocity, Vector3(0,1,0))
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
			if Input.is_action_just_pressed("jump"): # TODO: ECTE YOU NEED TO ASSIGN A BUTTON LOL find a better action for jumping
			#velocity.y=10
				if is_on_floor():
					velocity.y=jump_height
			velocity.y += gravity*delta
			velocity.x=direction.x
			velocity.z=direction.z
			
			velocity = move_and_slide(velocity,Vector3(0,1,0))
	
			

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
		if Globals.battleStatus==1:
			if self.is_on_floor():
				self.set_hp(self.get_hp()-1)
			else:
				self.get_parent().enemy.receiveDamage(1)
				get_parent().reachedTarget=1
				self.velocity.x=0
		else:
			if self.is_on_floor():
				get_parent().emit_signal("main_startBattle",false)
			else:
				get_parent().emit_signal("main_startBattle",true)
			#yield(get_parent(), "main_startBattle")
			#yield(get_parent(),"main_startBattle(true)")

	#if body is RigidBody:#Area: # TODO: What type will enemy be? Assuming area for now.
	#	body.hide() # eliminate enemy as a test

