extends Spatial
signal startBattle(freeAttack)
signal endBattle(playerWins)

var onceOnly=1
var reachedTarget=0
var startedAttack=0
var attackStarted=false
var response=""
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var globals = true
export (PackedScene) var PlayerScene

var player: KinematicBody

export (PackedScene) var EnemyScene

var enemy: RigidBody
var player_camera = Camera.new()
var enemy_camera = Camera.new()

var playerPos: Vector3
var enemyPos: Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	setupBattleSettings()
	load_players_and_enemies()
	load_and_setup_cameras()
	position_players_and_enemies()
	setupHUD()
	
func setupHUD():
	$HUD.startBattle(true)
	yield(get_tree().create_timer(3.0), "timeout")
	$HUD.update(getPlayerSettings(player))
	$HUD.showGUI(0)

func position_players_and_enemies():
	player.transform.origin.x=$PlayerSpawn.transform.origin.x
	player.transform.origin.z=$PlayerSpawn.transform.origin.z
	
	enemy.transform.origin.x=$EnemySpawn.transform.origin.x
	enemy.transform.origin.y=player.transform.origin.y
	enemy.transform.origin.z=$EnemySpawn.transform.origin.z
	player.get_child(0).flip_h=true

	playerPos=player.transform.origin
	enemyPos=enemy.transform.origin

func load_and_setup_cameras():
	player.add_child(player_camera)
	enemy.add_child(enemy_camera)
	player_camera=player.get_child(player.get_child_count()-1)
	enemy_camera=enemy.get_child(enemy.get_child_count()-1)
	player_camera.translate(Vector3(0,5,12))
	enemy_camera.translate(Vector3(0,5,9))
	player_camera.current=true
	player_camera.look_at(player.transform.origin,Vector3.UP)


func load_players_and_enemies():
	var playerR=load("res://Mario.tscn")
	var enemyR=load("res://Goombah.tscn")
	player=playerR.instance()
	enemy=enemyR.instance()
	add_child(player)
	add_child(enemy)


func setupBattleSettings():
	if Globals.playerGoesFirst==true:
		_on_BattleArena_startBattle(true)
		Globals.setPlayerGoesFirst(true)
	if Globals.playerGoesFirst==false:
		_on_BattleArena_startBattle(false)
		Globals.setPlayerGoesFirst(false)

	
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
	return enemy

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
			if response=="Jump" and attackStarted!=true:
				attackStarted=true
			else:
				response = $HUD.showTurnPanel()
			player.velocity=playerAttack(delta)
			if reachedTarget==1:
				Globals.playerTurn=false
				Globals.playerGoesFirst=false
		else:
			yield()
#	pass



func _on_BattleArena_startBattle(freeAttack):
	#breakpoint
	if freeAttack:
		setPlayerGoesFirst(true)
	Globals.battleStatus=1

		
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
