extends Spatial
signal startBattle(freeAttack)
signal endBattle(playerWins)

var onceOnly=1
var reachedTarget=false
var startedAttack=0
var playerAttackStarted=false
var enemyAttackStarted=false
var playerAttackFinished=false
var enemyAttackFinished=false
var response=""
var plrAttackPhase =-1
var startJump: bool = false
var doubleAttack: bool = false
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

var lerp_currentTime=0
var lerp_totalTime=3
var lerp_startPos
var lerp_endPos

# Called when the node enters the scene tree for the first time.
func _ready():
	setupBattleSettings()
	load_players_and_enemies()
	load_and_setup_cameras()
	position_players_and_enemies()
	setupHUD()
	print_debug(player.transform.origin)
	
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

func resetCombatants():
	position_players_and_enemies()

func playerAttack(delta):
	playerAttackStarted=true
	reachedTarget=false
	var newPosition
	if $PlayerSpawn/PlayerAttack_AnimationPlayer.is_playing()==false:
		$PlayerSpawn/PlayerAttack_AnimationPlayer.play("jump")
		newPosition=$PlayerSpawn.transform.origin
	else:
		newPosition=$PlayerSpawn.transform.origin
		if player.transform.origin.y>2.5015:
			player.state=player.states.JUMP
			player.hflip(true)
		else:
			player.state=player.states.E
			player.direction=Vector3(1,0,0)
	if playerAttackFinished == true:
	#if newPosition.x==5.887784: #enemy.transform.origin.x:
		yield(get_tree().create_timer(0.75), "timeout")
		reachedTarget=true
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
			if response=="Jump" and playerAttackStarted!=true:
				playerAttackStarted=true
			else:
				while response=="":
					response = $HUD.showTurnPanel()
					if response=="": 
						yield()
			if playerAttackStarted:
				var newPos = playerAttack(delta)
				if reachedTarget==false and playerAttackFinished==false:
					player.set_positionV3(newPos)
				else:
					$HUD/BattlePanel3.popup()
					yield(get_tree().create_timer(0.75), "timeout")
					reachedTarget=false
					var numAttacks=1
					var player_original_position = player.transform.origin
					if doubleAttack==true:
						numAttacks=2
					for x in range(1, numAttacks):
						player.transform.origin = player_original_position
						player.move_and_slide(Vector3(0,player.gravity,0), Vector3.UP)
					reachedTarget=true
				if reachedTarget==true:
					Globals.playerTurn=false
					Globals.playerGoesFirst=false
					playerAttackStarted=false
		else:
			yield()
#	pass

#func playerJump(delta):
#	if plrJumpPhase==3:
#		return true
	

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


func _on_PlayerAttack_AnimationPlayer_animation_finished(anim_name):
	playerAttackFinished = true
	pass # Replace with function body.
