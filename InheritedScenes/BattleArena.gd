extends Spatial
signal startBattle(freeAttack)
signal endBattle(playerWins)

var onceOnly=1
var reachedTarget=0
var startedAttack=0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var globals = true
export (NodePath) var player
export (NodePath) var enemy



var playerPos: Vector3
var enemyPos: Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	#var petals = Globals.petals
	#var stars = Globals.stars
	#var coins = Globals.coins

	if Globals.playerGoesFirst==true:
		_on_BattleArena_startBattle(true)
		Globals.setPlayerGoesFirst(true)
	if Globals.playerGoesFirst==false:
		_on_BattleArena_startBattle(false)
		Globals.setPlayerGoesFirst(false)
	var playerR=load("res://Mario.tscn")
	var enemyR=load("res://Goombah.tscn")
	player=load("res://Mario.tscn").instance()
	enemy=load("res://Goombah.tscn").instance()
	add_child(player)
	add_child(enemy)
	player.add_child($PlayerCamera)
	enemy.add_child($EnemyCamera)
	print_tree_pretty()
	player.transform.origin=$PlayerSpawn.transform.origin
	enemy.transform.origin=$EnemySpawn.transform.origin
	player.get_child(0).flip_h=true
	$Goombah.free()
	$Mario.free()
	playerPos=player.transform.origin
	enemyPos=enemy.transform.origin
	$HUD.update_hp(player.get_hp())
	$HUD.update_petals(player.get_pp())
	$HUD.update_stars(player.get_sp())
	$HUD.update_coins(player.coins)
	
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
		
func getWorldEdge():
	return $BattleStage.get_child(0).scale
func getEnemy():
	return get_node(enemy)

func setPlayerGoesFirst(value: bool):
	Globals.setPlayerGoesFirst(value)

func playerAttack(delta):
	var velocity=Vector3(player.velocity.x, player.velocity.y, player.velocity.z)
	startedAttack=1
	var target = enemy.transform.origin #attackPath_points[attackPath_index-1]
	var position = player.transform.origin
	if position.distance_to(target) < 4.5:
		if reachedTarget==0:
			if onceOnly == 1:
				onceOnly = 0
				velocity.x=1*player.speed*delta
				velocity.y=player.jump_height
				#reachedTarget=1
		else:
			velocity.x = 0
			velocity.y = 0
			velocity.z = 0
			player.direction=Vector3.ZERO
			player.transform.origin = playerPos
	else:
		if reachedTarget == 0:
			velocity = (target - position).normalized() * player.speed * delta
	
	return velocity
			
	#if attackPath_index < attackPath_points.size():
	#	attackPath_index=attackPath_index+1
	#else:
	#	if onceOnly == 1:
	#		onceOnly=0
			
	#	else:
	#		velocity.x=0
			
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.battleStatus==1:
		if Globals.playerTurn==true:
			player.velocity=playerAttack(delta)
			if reachedTarget==1:
				Globals.playerTurn=false
				Globals.playerGoesFirst=false
		else:
			yield()
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
