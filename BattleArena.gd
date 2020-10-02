extends Spatial
signal startBattle(freeAttack)
signal endBattle(playerWins)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var globals = true
export (NodePath) var player
export (NodePath) var enemy

# Called when the node enters the scene tree for the first time.
func _ready():
	var petals = Globals.petals
	var stars = Globals.stars
	var coins = Globals.coins
	$HUD.update_hp($Mario.get_hp())
	$HUD.update_petals(petals)
	$HUD.update_stars(stars)
	$HUD.update_coins(coins)
	if Globals.playerGoesFirst==true:
		_on_BattleArena_startBattle(true)
		Globals.setPlayerGoesFirst(true)
	if Globals.playerGoesFirst==false:
		_on_BattleArena_startBattle(false)
		Globals.setPlayerGoesFirst(false)
		
func getworldEdge():
	return $Floor.global_scale()
		
func getEnemy():
	return get_node(enemy)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_BattleArena_startBattle(freeAttack):
	#breakpoint
	Globals.startBattle(freeAttack)
#	if freeAttack:
		
		#attack($Mario)
#	else:
#		attack($Goombah)

#func attack(object):
#	if object.is_in_group("Player"):
#		$Mario.attack()
#	else:
#		get_tree().call_group("Enemies", "attack()")


func _on_BattleArena_endBattle(playerWins):
	Globals.endBattle(playerWins)
