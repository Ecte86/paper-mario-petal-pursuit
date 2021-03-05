extends Spatial
export (PackedScene) var Mob

const CONST_DEBUG = true # Switch this to off later?

#signal startBattle

#signal main_startBattle(playerGoesFirst)

var lastCollisionPartner

var battleArena

# Declare member variables here.Examples:
#var a = 2
#var b = "text"

var playerSettings = []

export (PackedScene) var PlayerScene

var bUpdateHUD_Reward = false

var Mario

var MarioCamera: Camera

var CurrentPlayerPosition: Vector3 = Vector3.ZERO

var cameraDistance: float

var prev_cameraDistance: float

# Called when the node enters the scene tree for the first time.
func _ready():
	# This is all self explanatory, sort of, but:
	
	# 1. load and display Mario and enemies
	self.load_players_and_enemies()
	$Goomba.transform.origin.y=1.147
	Mario.transform.origin.y=0.056
	print_debug(Mario.transform.origin)
	print_debug($Goomba.transform.origin)
	# 2. preload the battle arena (where we battle with any enemies)
	#	 and setup the HUD (on-screen elements)
	self.preload_BattleArena_and_setup_HUD()
	# 3. setup the cameras 
	self.setup_cameras()
	#print_tree_pretty()

	var extraMario = self.get_child(self.get_child_count()-2)
	var extraCamera = self.get_child(self.get_child_count()-1)
	var lastNode_idx = self.get_child_count()-2
	print_debug(extraCamera.name)
	if extraMario.name == "Mario5":
		self.remove_child(self.get_child(lastNode_idx))
		self.remove_child(extraCamera)
		load_players_and_enemies()

func preload_BattleArena_and_setup_HUD():
	# Update the GUI's stats from the mro
	$HUD.update(getPlayerSettings(Mario))
	# Show the GUI, briefly. This is optional, but I included it as a test 
	$HUD.showGUI()
	if Globals.last_battle_reward != null:
		bUpdateHUD_Reward=true
	# We aren't in a battle so set battleStatus to false
	Globals.battleStatus = false
	# Start the Background Music
	$BackgroundMusic.play()
	# Load the Battle Arena, ready for displaying
	battleArena = load("res://Scenes/BattleArena.tscn")

func setup_cameras():
	#Add a new camera at the bottom of Main's tree.
	self.add_child(Camera.new())
	# Give it a variable so we can refer to it
	MarioCamera = self.get_child(self.get_child_count() - 1)
	# Move it to a new position
	MarioCamera.translate(Vector3(0, 5, CurrentPlayerPosition.z+9))
	# Set our view to it.
	MarioCamera.current = true
	# Tell camera to look at mario's position
	CurrentPlayerPosition = Mario.transform.origin + Vector3(0,2,0)
	MarioCamera.look_at(CurrentPlayerPosition, Vector3.UP)

func load_players_and_enemies():
	#Load Mario.
	Mario=Globals.get_Mario()
	#Add Mario at the bottom of Main's tree
	self.add_child(Mario)
	#Player is now Mario
	Mario = self.get_node(Mario.get_path())
	#Load settings from Global mario
	#self.setPlayerSettings(Mario, Globals.getPlayerSettings(Mario))
	#Note: Mario position is set to the middle of the Scene
	
	if Globals.last_battle_winner != 0:
		if Globals.last_battle_winner == Globals.BattleWinner.ENEMY:
			MarioCamera.look_at($Goomba.transform.origin,Vector3.UP)
			Mario.direction=Vector3.ZERO
		else:
			$Goomba.hide()
			$Label.show()
			#Mario.transform.origin=$Goomba.transform.origin

func getWorldEdge():
	# The floor's size, so we can refer to it with less typing
	return $Floor.get_child(0).scale

func getPlayerSettings(mro):
	# Get all Mario's settings and stuff it into an array
	return [mro.name,
		mro.getHeartPoints(),
		mro.getFlowerPoints(),
		mro.getBadgePoints(),
		mro.getStarPoints(),
		mro.getLevel(),
		mro.getPetalPower(),
		mro.getCoins()
	]

func setPlayerSettings(mro, settings: Array):
	# Given Mario's settings in an array, set them up all at once
	mro.setHeartPoints(settings[1])
	mro.setFlowerPoints(settings[2])
	mro.setBadgePoints(settings[3])
	mro.setStarPoints(settings[4])
	mro.setLevel(settings[5])
	mro.setPetalPower(settings[6])
	mro.setCoins(settings[7])

func _on_Main_main_startBattle(playerGoesFirst):
	# playerGoesFirst is a variable that gets set true or false depending on
	# whether we made an attack (in which case it'd be true) or whether we were
	# attacked (in which case it'd be false)
	
	# Set up a new Scene in a variable
	var arenaScene = battleArena.instance()
	# If we attacked first...
	if playerGoesFirst == true:
		# ... then we get to have first attack
		Globals.setPlayerGoesFirst(true)
		# update Global Mario with a copy of Mario's node
		Globals.set_Mario(Mario.duplicate())
		# do the same with the enemy we are attacking
		Globals.set_Enemy($Goomba.duplicate())
		Globals.node_Enemy.set_Heart_Points($Goomba.get_Heart_Points()-1)
	else :
		# otherwise it'd not our turn
		Globals.setPlayerGoesFirst(false)
		# we still need to update Global Mario tho
		Globals.set_Mario(Mario.duplicate())
		# and again with the enemy
		Globals.set_Enemy($Goomba.duplicate())
	# Add our new Scene to the tree when we are all done here, and show it
	get_tree().root.call_deferred("add_child", arenaScene)
	# Clear up memory/other events
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# This is a badly designed method, I know, since its got a lot of stuff 
	# mixed together
	
	# Check for user input (besides movement)
	_processUserInput(delta)
	
	# Make sure camera follows Mario
	_processCamera(delta)
	
	# Again, this is poorly designed, but check if Mario is colliding with 
	# stuff
	_processPlayerCollisions(delta)
	
	if bUpdateHUD_Reward == true:
		for x in range(Globals.last_battle_reward.size()):
			if Globals.last_battle_reward[x] != null:
				var reward_amount = Globals.last_battle_reward[x]
				$HUD.RewardCount(x, reward_amount)
#				yield(get_tree().create_timer(0.1), "timeout")
		bUpdateHUD_Reward=false

	
func _processPlayerCollisions(delta):
	# Loop through any objects Mario is colliding with
	for i in Mario.get_slide_count():
		# put them into collider variable
		var collider = Mario.get_slide_collision(i)
		# if we find any, get the most recent one and run the collision event
		if collider:
			_on_Mario_hit(Mario.get_last_collision_partner())

func _processCamera(delta):
	# Try to get the camera to follow the player, but not follow them off the 
	# edge of the level.
	# This is a WORK IN PROGRESS. Its a bit janky atm.
	
	# Get camera's current position in the Scene
	var oldCameraPos = self.to_global(MarioCamera.transform.origin)
	# Get mro's current position in the Scene
	var playerPos = self.to_global(Mario.transform.origin)
	# look at them
	MarioCamera.look_at(Mario.transform.origin, Vector3.UP)
	# Follow Mario left & right
	MarioCamera.transform.origin.x = Mario.transform.origin.x
	# Get the edge of the world
	var edge = getWorldEdge()
	# Stop the camera if we reach the edge
	MarioCamera.global_transform.origin.x = clamp(MarioCamera.global_transform.origin.x, -edge.x / 2, edge.x / 2)
	# Follow Mario forward & back if they get too far
	var distanceTo=playerPos.distance_to(oldCameraPos)
	if distanceTo>9 or distanceTo<5:
		if playerPos.distance_to(oldCameraPos)>9:
			while playerPos.distance_to(oldCameraPos)>9:
				MarioCamera.translate_object_local(Vector3.FORWARD*delta)
				yield()
		if playerPos.distance_to(oldCameraPos)<5:
			while playerPos.distance_to(oldCameraPos)<5:
				MarioCamera.translate_object_local(Vector3.BACK*delta)
				yield()


func _processUserInput(_delta):
	# If user presses tab, show the stats GUI 
	# TODO: add a check for the equivalent button on a Nintendo controller
	if Input.is_action_just_pressed("ui_focus_next"):
		showGUI()
	if Input.is_action_pressed("ui_home") and CONST_DEBUG==true:
		if $BackgroundMusic.playing==true:
			$BackgroundMusic.stop()
		else:
			$BackgroundMusic.play()

func showGUI(duration = 3, forever = false):
	# A general function that shows the gui for as long as specified.
	# Default = 3.
	# If forever = true, don't hide it.
	$HUD.showGUI(duration, forever)

func hideGUI():
	# Hide the GUI.
	$HUD.hideGUI()

func _on_Mario_hit(body):
	# if the thing we collided with (body) is in the group "Enemies"...
	if body.is_in_group("Enemies"): # (NEED TO FIND OUT HOW TO CHECK WHAT WE COLLIDING WITH)
		# ...and if Mario is on the floor
		if (Mario.isOnFloor()):
			#...then start a battle, but we don't get first attack
			_on_Main_main_startBattle(false)
		#...otherwise, we attacked the enemy...
		else :
			#...so start a battle, we get first attack
			_on_Main_main_startBattle(true)
			body.receive_damage(1)
