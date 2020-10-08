extends Spatial
export (PackedScene) var Mob

#signal startBattle

signal main_startBattle(playerGoesFirst)

var lastCollisionPartner

<<<<<<< HEAD
=======
var battleArena

>>>>>>> Ectes-stuff
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

<<<<<<< HEAD
var current_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	$Mario.new_game()
	$AudioStreamPlayer3D.play()
	$HUD.update_hp($Mario.get_hp())
	$HUD.update_petals(Globals.petals)
	$HUD.update_stars(Globals.stars)
	$HUD.update_coins(Globals.coins)
	Globals.battleStatus=0
=======
var playerSettings = []

export (PackedScene) var PlayerScene

var player: KinematicBody

var camera

# Called when the node enters the scene tree for the first time.
func _ready():
	self.load_players_and_enemies()
	self.setup_cameras()
	self.preload_BattleArena_and_setup_HUD()
>>>>>>> Ectes-stuff
#	var BattleArenaNode = get_tree()
#	BattleArenaNode.connect("startBattle", self, "_on_Main_main_startBattle")#connect("startBattle",self,"handleplayerspotted")

func preload_BattleArena_and_setup_HUD():
	player.new_game()
	$HUD.showGUI()
	$HUD.update(getPlayerSettings(player))
	Globals.battleStatus=0
	$BackgroundMusic.play()
	battleArena=load("res://InheritedScenes/BattleArena.tscn")
	print_debug($Floor.get_child(0).scale)

func setup_cameras():
	player.add_child(Camera.new())
	camera=player.get_child(player.get_child_count()-1)
	camera.translate(Vector3(0,5,9))
	camera.current=true
	camera.look_at(player.transform.origin,Vector3.UP)

func load_players_and_enemies():
	PlayerScene = preload("res://Mario.tscn")
	player = PlayerScene.instance()
	self.add_child(player)
	player = self.get_node(player.get_path())



func getWorldEdge():
	return $Floor.get_child(0).scale

func getPlayerSettings(player):
	return [player.name,
		player.getHeartPoints(),
		player.getFlowerPoints(),
		player.getBadgePoints(),
		player.getStarPoints(),
		player.getLevel(),
		player.getPetalPower(),
		player.getCoins()]
	
func setPlayerSettings(player, settings: Array):
	player.setHeartPoints(settings[1])
	player.setFlowerPoints(settings[2])
	player.setBadgePoints(settings[3])
	player.setStarPoints(settings[4])
	player.setLevel(settings[5])
	player.setPetalPower(settings[6])
	player.setCoins(settings[7])

func _on_Main_main_startBattle(playerGoesFirst):
<<<<<<< HEAD
	Globals.goto_scene("res://BattleArena.tscn")
=======
	#Globals.goto_scene("res://BattleArena.tscn")
	var arenaScene=battleArena.instance()
>>>>>>> Ectes-stuff
	if playerGoesFirst == true:
		$HUD.startBattle(true)
		yield(get_tree().create_timer(3.0), "timeout")
		arenaScene.setPlayerGoesFirst(true)
		arenaScene.setPlayerSettings(player, self.getPlayerSettings(player))
		#Globals.setPlayerGoesFirst(playerGoesFirst)
		#get_tree().call_group("BattleArena", "_on_BattleArena_startBattle(true)")
				#get_tree().get_root().emit_signal("startBattle", true)
	else:
		arenaScene.setPlayerGoesFirst(false)
		#Globals.setPlayerGoesFirst(playerGoesFirst)
	get_tree().root.call_deferred("add_child", arenaScene)
	queue_free()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_focus_next"):
		$HUD.showGUI()
	for i in player.get_slide_count():
		var collider = player.get_slide_collision(i)
		if collider:
<<<<<<< HEAD
			lastCollisionPartner = ($Mario.get_last_collision_partner())
#	pass


func _on_Mario_hit():
#	#print_debug(str(body.collider.get_parent().get_parent().get_groups()))
#	#print_debug(str(body.get_groups()))

	if lastCollisionPartner.is_in_group("Enemies"): # NEED TO FIND OUT HOW TO CHECK WHAT WE COLLIDING WITH
		if ($Mario.isOnFloor()):
=======
			_on_Mario_hit(player.get_last_collision_partner())
#	pass


func _on_Mario_hit(body):
	#print_debug(str(body.collider.get_parent().get_parent().get_groups()))
	#print_debug(str(body.get_groups()))
	if body.is_in_group("Enemies"): # NEED TO FIND OUT HOW TO CHECK WHAT WE COLLIDING WITH
		if (player.isOnFloor()):
>>>>>>> Ectes-stuff
			_on_Main_main_startBattle(false)
			#emit_signal("main_startBattle", false)
		else:
#
			_on_Main_main_startBattle(true)
#			#emit_signal("main_startBattle", true)
