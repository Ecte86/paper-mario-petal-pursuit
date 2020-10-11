extends Spatial
export (PackedScene) var Mob

#signal startBattle

signal main_startBattle(playerGoesFirst)

var lastCollisionPartner

var battleArena

# Declare member variables here.Examples:
#var a = 2
#var b = "text"

var playerSettings = []

export (PackedScene) var PlayerScene

var player: KinematicBody

var MarioCamera: Camera

var CurrentPlayerPosition: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	# This is all self explanatory, sort of, but:
	
	# 1. load and display yMario and enemies
	self.load_players_and_enemies()
	
	# 2. preload the battle arena (where we battle with any enemies)
	#	 and setup the HUD (on-screen elements)
	self.preload_BattleArena_and_setup_HUD()
	# 3. setup the cameras (still a Work in Progress.
	#	 Cameras are a bit wierd atm) 
	self.setup_cameras()

func preload_BattleArena_and_setup_HUD():
	# Tell Mario to reset stats 
	player.new_game()
	# Update the GUI's stats from the player
	$HUD.update(getPlayerSettings(player))
	# Show the GUI, briefly. This is optional, but I included it as a test 
	$HUD.showGUI()
	# We aren't in a battle so set battleStatus to 0
	Globals.battleStatus = 0
	# Start the Background Music
	$BackgroundMusic.play()
	# Load the Battle Arena, ready for displaying
	battleArena = load("res://InheritedScenes/BattleArena.tscn")

func setup_cameras():
	#Add a new camera at the bottom of Main's tree.
	self.add_child(Camera.new())
	# Give it a variable so we can refer to it
	MarioCamera = self.get_child(self.get_child_count() - 1)
	# Move it to a new position
	MarioCamera.translate(Vector3(0, 5, 9))
	# Set our view to it.
	MarioCamera.current = true
	# Tell camera to look at player's position
	CurrentPlayerPosition = player.transform.origin
	MarioCamera.look_at(CurrentPlayerPosition, Vector3.UP)

func load_players_and_enemies():
	#Load Mario.
	PlayerScene = preload("res://Mario.tscn")
	#Instance Mario
	player = PlayerScene.instance()
	#Add Mario at the bottom of Main's tree
	self.add_child(player)
	#Player is now Mario
	player = self.get_node(player.get_path())

func getWorldEdge():
	# The floor's size, so we can refer to it with less typing
	return $Floor.get_child(0).scale

func getPlayerSettings(player):
	# Get all Mario's settings and stuff it into an array
	return [player.name,
		player.getHeartPoints(),
		player.getFlowerPoints(),
		player.getBadgePoints(),
		player.getStarPoints(),
		player.getLevel(),
		player.getPetalPower(),
		player.getCoins()
	]

func setPlayerSettings(player, settings: Array):
	# Given Mario's settings in an array, set them up all at once
	player.setHeartPoints(settings[1])
	player.setFlowerPoints(settings[2])
	player.setBadgePoints(settings[3])
	player.setStarPoints(settings[4])
	player.setLevel(settings[5])
	player.setPetalPower(settings[6])
	player.setCoins(settings[7])

func _on_Main_main_startBattle(playerGoesFirst):
	# Set up a new Scene in a variable
	var arenaScene = battleArena.instance()
	# If we attacked first...
	if playerGoesFirst == true:
		# ... then we get to have first attack
		arenaScene.setPlayerGoesFirst(true)
		# setup a new version of Mario with our current Mario's stats
		arenaScene.setPlayerSettings(player, self.getPlayerSettings(player))
	else :
		# otherwise it'd not our turn
		arenaScene.setPlayerGoesFirst(false)
		# we still need to setup a new version of Mario tho
		arenaScene.setPlayerSettings(player, self.getPlayerSettings(player))
	# Add our new Scene to the tree when we are all done here, and show it
	get_tree().root.call_deferred("add_child", arenaScene)
	# Clear up memory/other events
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_focus_next"):
		showGUI()
	var oldCameraPos = self.to_global(MarioCamera.transform.origin)
	var playerPos = self.to_global(player.transform.origin)
	if player.transform.origin.y > oldCameraPos.y:
		MarioCamera.look_at(player.transform.origin, Vector3.UP)
		if player.velocity.y == 0:
			MarioCamera.translate(Vector3(0, playerPos.y - oldCameraPos.y, 0))
	if player.transform.origin.y < MarioCamera.transform.origin.y:
		MarioCamera.look_at(player.transform.origin, Vector3.UP)
	MarioCamera.transform.origin.x = player.transform.origin.x
	var edge = getWorldEdge()
	MarioCamera.global_transform.origin.x = clamp(MarioCamera.global_transform.origin.x, -edge.x / 2, edge.x / 2)
	for i in player.get_slide_count():
		var collider = player.get_slide_collision(i)
		if collider:
			_on_Mario_hit(player.get_last_collision_partner())

func showGUI(duration = 3, forever = false):
	$HUD.showGUI(duration, forever)

func hideGUI():
	$HUD.hideGUI()

func _on_Mario_hit(body):
	if body.is_in_group("Enemies"): # NEED TO FIND OUT HOW TO CHECK WHAT WE COLLIDING WITH
		if (player.isOnFloor()):
			_on_Main_main_startBattle(false)
		else :
			_on_Main_main_startBattle(true)
