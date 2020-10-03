extends Spatial
export (PackedScene) var Mob

#signal startBattle

signal main_startBattle(playerGoesFirst)

var lastCollisionPartner

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

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
#	var BattleArenaNode = get_tree()
#	BattleArenaNode.connect("startBattle", self, "_on_Main_main_startBattle")#connect("startBattle",self,"handleplayerspotted")

func getWorldEdge():
	return $Floor.get_child(0).scale

func _on_Main_main_startBattle(playerGoesFirst):
	Globals.goto_scene("res://BattleArena.tscn")
	if playerGoesFirst == true:
		Globals.setPlayerGoesFirst(playerGoesFirst)
		#get_tree().call_group("BattleArena", "_on_BattleArena_startBattle(true)")
				#get_tree().get_root().emit_signal("startBattle", true)
	else:
		Globals.setPlayerGoesFirst(playerGoesFirst)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in $Mario.get_slide_count():
		var collider = $Mario.get_slide_collision(i)
		if collider:
			lastCollisionPartner = ($Mario.get_last_collision_partner())
#	pass


func _on_Mario_hit():
#	#print_debug(str(body.collider.get_parent().get_parent().get_groups()))
#	#print_debug(str(body.get_groups()))

	if lastCollisionPartner.is_in_group("Enemies"): # NEED TO FIND OUT HOW TO CHECK WHAT WE COLLIDING WITH
		if ($Mario.isOnFloor()):
			_on_Main_main_startBattle(false)
			#emit_signal("main_startBattle", false)
		else:
#
			_on_Main_main_startBattle(true)
#			#emit_signal("main_startBattle", true)
