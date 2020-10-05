extends Spatial
export (PackedScene) var Mob

#signal startBattle

signal main_startBattle(playerGoesFirst)

<<<<<<< Updated upstream
=======
var lastCollisionPartner

var battleArena

>>>>>>> Stashed changes
# Declare member variables here. Examples:
# var a = 2
# var b = "text"



# Called when the node enters the scene tree for the first time.
func _ready():
	$Mario.new_game()
	$HUD.update_hp($Mario.get_hp())
	$HUD.update_petals(Globals.petals)
	$HUD.update_stars(Globals.stars)
	$HUD.update_coins(Globals.coins)
<<<<<<< Updated upstream
=======
	Globals.battleStatus=0
	$BackgroundMusic.play()
	battleArena=load("res://InheritedScenes/BattleArena.tscn")
>>>>>>> Stashed changes
#	var BattleArenaNode = get_tree()
#	BattleArenaNode.connect("startBattle", self, "_on_Main_main_startBattle")#connect("startBattle",self,"handleplayerspotted")

func getWorldEdge():
	return $Floor.get_child(0).scale

func _on_Main_main_startBattle(playerGoesFirst):
<<<<<<< Updated upstream
	get_tree().change_scene("res://BattleArena.tscn")
=======
	#Globals.goto_scene("res://BattleArena.tscn")
	var arenaScene=battleArena.instance()
>>>>>>> Stashed changes
	if playerGoesFirst == true:
		arenaScene.setPlayerGoesFirst(true)
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
