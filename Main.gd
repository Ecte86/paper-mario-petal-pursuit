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

# Called when the node enters the scene tree for the first time.
func _ready():
	$Mario.new_game()
	$HUD.update_hp($Mario.getHeartPoints())
	$HUD.update_petals($Mario.getFlowerPoints())
	$HUD.update_stars($Mario.getStarPoints())
	$HUD.update_coins($Mario.getCoins())

	Globals.battleStatus=0
	$BackgroundMusic.play()
	battleArena=load("res://InheritedScenes/BattleArena.tscn")
#	var BattleArenaNode = get_tree()
#	BattleArenaNode.connect("startBattle", self, "_on_Main_main_startBattle")#connect("startBattle",self,"handleplayerspotted")

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
		arenaScene.setPlayerGoesFirst(true)
		arenaScene.setPlayerSettings(self.getPlayerSettings($Mario))
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
	for i in $Mario.get_slide_count():
		var collider = $Mario.get_slide_collision(i)
		if collider:
			_on_Mario_hit($Mario.get_last_collision_partner())
#	pass


func _on_Mario_hit(body):
	#print_debug(str(body.collider.get_parent().get_parent().get_groups()))
	#print_debug(str(body.get_groups()))
	if body.is_in_group("Enemies"): # NEED TO FIND OUT HOW TO CHECK WHAT WE COLLIDING WITH
		if ($Mario.isOnFloor()):
			_on_Main_main_startBattle(false)
			#emit_signal("main_startBattle", false)
		else:
			_on_Main_main_startBattle(true)
			#emit_signal("main_startBattle", true)
