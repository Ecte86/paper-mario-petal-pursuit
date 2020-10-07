extends Spatial
export (PackedScene) var Mob

#signal startBattle

signal main_startBattle(playerGoesFirst)

var lastCollisionPartner

var battleArena

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var playerSettings = []

export (PackedScene) var PlayerScene

var player: KinematicBody

var MarioCamera: Camera

var CurrentPlayerPosition: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	self.load_players_and_enemies()
	self.preload_BattleArena_and_setup_HUD()
	self.setup_cameras()
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
	self.add_child(Camera.new())
	MarioCamera=self.get_child(self.get_child_count()-1)
	print_tree_pretty()
	MarioCamera.translate(Vector3(0,5,9))
	MarioCamera.current=true
	CurrentPlayerPosition = player.transform.origin
	MarioCamera.look_at(CurrentPlayerPosition,Vector3.UP)

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
	#Globals.goto_scene("res://BattleArena.tscn")
	var arenaScene=battleArena.instance()
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
#	if CurrentPlayerPosition != player.to_global(player.transform.origin):
	var oldCameraPos=self.to_global(MarioCamera.transform.origin)
	var playerPos=self.to_global(player.transform.origin)
	if player.transform.origin.y>oldCameraPos.y:
		MarioCamera.look_at(player.transform.origin,Vector3.UP)
		if player.velocity.y==0:
			MarioCamera.translate(Vector3(0,playerPos.y-oldCameraPos.y,0))
	if player.transform.origin.y<MarioCamera.transform.origin.y:
		MarioCamera.look_at(player.transform.origin,Vector3.UP)
#		if player.velocity.y==0:
#			MarioCamera.translate(Vector3(0,(oldCameraPos.y-playerPos.y,0)))
			

			
	#MarioCamera.look_at(player.transform.origin,Vector3.UP)
	MarioCamera.transform.origin.x=player.transform.origin.x
	var edge = getWorldEdge()
	MarioCamera.global_transform.origin.x = clamp(MarioCamera.global_transform.origin.x,-edge.x/2,edge.x/2)	
		#MarioCamera.call("update_camera", CurrentPlayerPosition)#.update_camera(CurrentPlayerPosition)
	if Input.is_action_pressed("ui_focus_next"):
		$HUD.showGUI()
	for i in player.get_slide_count():
		var collider = player.get_slide_collision(i)
		if collider:
			_on_Mario_hit(player.get_last_collision_partner())
#	pass


func _on_Mario_hit(body):
	#print_debug(str(body.collider.get_parent().get_parent().get_groups()))
	#print_debug(str(body.get_groups()))
	if body.is_in_group("Enemies"): # NEED TO FIND OUT HOW TO CHECK WHAT WE COLLIDING WITH
		if (player.isOnFloor()):
			_on_Main_main_startBattle(false)
			#emit_signal("main_startBattle", false)
		else:
			_on_Main_main_startBattle(true)
			#emit_signal("main_startBattle", true)
