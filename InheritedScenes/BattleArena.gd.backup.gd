extends Spatial
signal startBattle(freeAttack)
signal endBattle(playerWins)

var onceOnly=true
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
var battleStatus: bool
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

var time_limited_input_check
var input_timer = 0
var input_timer_max = 0.750

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
	#player.setup()
	player.transform.origin.x=$PlayerSpawn.transform.origin.x
	player.transform.origin.y=$PlayerSpawn.transform.origin.y
	player.transform.origin.z=$PlayerSpawn.transform.origin.z
	
	enemy.transform.origin.x=$EnemySpawn.transform.origin.x
	enemy.transform.origin.y=$EnemySpawn.transform.origin.y
	enemy.transform.origin.z=$EnemySpawn.transform.origin.z

	#playerPos=player.transform.origin
	#enemyPos=enemy.transform.origin
	#player.get_child(0).flip_h=true
	
	player.get_child(0).play("idleDown")
	
#	player.move_and_slide_with_snap(Vector3(0,5,0),Vector3.DOWN,Vector3.UP)
#	player.move_and_slide_with_snap(Vector3(0,-5,0),Vector3.DOWN,Vector3.UP)

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
	if Globals.playerTurn:
		Globals.playerTurn=false
		Globals.playerGoesFirst=false
	else:
		if Globals.enemy_turn_finished==true:
			Globals.playerTurn=true
		
	player.direction=Vector3.ZERO
	player.velocity=Vector3.ZERO
	$PlayerSpawn/PlayerAttack_AnimationPlayer.seek(0,true)
	position_players_and_enemies()

func playerAttack(delta):
	playerAttackStarted=true
	reachedTarget=false
	var newPosition
	if $PlayerSpawn/PlayerAttack_AnimationPlayer.is_playing()==false:
		$PlayerSpawn/PlayerAttack_AnimationPlayer.play("run_and_jump_up")
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
		reachedTarget=true
	return newPosition


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.battleStatus==true:
		if Globals.playerTurn==true:
			if response=="Jump" and playerAttackStarted!=true:
				playerAttackStarted=true
			else:
				while response=="":
					response = $HUD.showTurnPanel()
					break
			if playerAttackStarted:
				var newPos = playerAttack(delta)
				if reachedTarget==false and playerAttackFinished==false:
					player.set_positionV3(newPos)
				else:
					var doubleAttack = false
					time_limited_input_check=true
					while input_timer<input_timer_max: 
						input_timer+=delta
						$HUD/BattlePanel3.popup()
						doubleAttack=player.checkforAttackInput()
						if doubleAttack==false:
							if input_timer>=input_timer_max:
								$HUD/BattlePanel3.hide()
								break
							yield()
						else:
							$HUD/BattlePanel3/GratsMessage.show()
							$HUD/BattlePanel3/NintendoAButton.hide()
							break
					input_timer=0
					reachedTarget=false
					var numAttacks=1
					var player_original_position = player.transform.origin
					if doubleAttack==true:
						numAttacks=2
					var hitEnemy=false
					if input_timer==0:
						for x in range(1, numAttacks+1): # we count to max - 1, so
													 # we add 1 to max 
#						if x > 1:
#							breakpoint
							if player.transform.origin != player_original_position:
								player.transform.origin = player_original_position
								yield()
							var playersFeet=player.transform.origin.y-player.scale.y
							var enemyHead=enemy.transform.origin.y+enemy.scale.y
							
							if $PlayerSpawn/PlayerAttack_AnimationPlayer.get_current_animation()!="jump_on":
								$PlayerSpawn/PlayerAttack_AnimationPlayer.play("jump_on")
							while $PlayerSpawn/PlayerAttack_AnimationPlayer.is_playing():
								yield()
						reachedTarget=true
						$HUD/BattlePanel3.hide()
					if reachedTarget==true:
						Globals.playerGoesFirst=false
						playerAttackStarted=false
						reachedTarget=false
						resetCombatants()
		else: # Its npt players turn
			if $PlayerSpawn/PlayerAttack_AnimationPlayer.is_playing():
				$PlayerSpawn/PlayerAttack_AnimationPlayer.stop(true)
			
			if enemy.get_Heart_Points(): # If Enemy is alive
				if enemy.visible==false:
					enemy.show()
	#			yield() # replace with turn!
			else:
				#enemy lost!
				enemy.hide()
				emit_signal("endBattle", "true")
#	pass

#func playerJump(delta):
#	if plrJumpPhase==3:
#		return true
	

func _on_BattleArena_startBattle(freeAttack):
	#breakpoint
	if freeAttack:
		setPlayerGoesFirst(true)
	self.battleStatus=true
	Globals.battleStatus=self.battleStatus

		
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


func _on_AttackInputTimer_timeout():
	time_limited_input_check=false
