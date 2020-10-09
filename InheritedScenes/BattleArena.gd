extends Spatial
signal startBattle(freeAttack)
signal endBattle(playerWins)

var onceOnly=1
var reachedTarget=false
var startedAttack=0
var attackStarted=false
var response=""
var plrJumpPhase =-1
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
	startedAttack=1
	var newPosition
	var velocity=Vector3.ZERO
	var target = enemy.transform.origin #attackPath_points[attackPath_index-1]
	var position = player.transform.origin
	if position.distance_to(target) < 4.5:
		if reachedTarget==false:
			if onceOnly == 1:
				onceOnly = 0
				velocity.x=1*player.speed*delta
				velocity.y=player.jumpAmount
				#player.move_and_slide(velocity)
				#reachedTarget=1
		else:
			velocity.x = 0
			velocity.y = 0
			velocity.z = 0
			player.direction=Vector3.ZERO
			player.transform.origin = playerPos
	else:
		if reachedTarget == false:
			var temp=Vector3(target.x-4.5,target.y,target.z)
			newPosition=lerp(position,target,delta)
			
			
	return newPosition
			
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
				while response=="":
					response = $HUD.showTurnPanel()
					if response=="": 
						yield()
			if attackStarted:
				var newPos = playerAttack(delta)
				if newPos != null:
					player.transform.origin=newPos
				else:
					reachedTarget=false
					var done = false
					if done == false:
						done = playerJump(delta)
					if done:
						player.move_and_slide(Vector3(0,player.gravity,0), Vector3.UP)
						#reachedTarget=true
				if reachedTarget==true:
					Globals.playerTurn=false
					Globals.playerGoesFirst=false
					attackStarted=false
		else:
			yield()
#	pass

func playerJump(delta):
	if plrJumpPhase ==-1:
		plrJumpPhase = 1
	var newPos
	var origPos = -1
	if origPos==-1:
		origPos=playerPos
	if plrJumpPhase == 1:
		newPos=playerPos
		newPos.y=newPos.y+enemy.scale.y # go up
		if player.transform.origin != newPos:
			player.transform.origin = \
				lerp(origPos, newPos,delta*2)
		else:
			plrJumpPhase=2
			origPos=-1
	if plrJumpPhase == 2:
		if origPos==-1:
			origPos=player.transform.origin
			newPos.x=enemy.transform.origin.x

		if player.transform.origin != newPos:
			print_debug(str(player.transform.origin)+"=>"+str(newPos))
			player.transform.origin = \
				lerp(origPos, newPos,delta*2)
		else:
			plrJumpPhase=3
	if plrJumpPhase==3:
		return true
	

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
