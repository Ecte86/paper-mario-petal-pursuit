extends Spatial
signal startBattle(freeAttack)
signal endBattle(playerWins)
signal mario_hit()


var player_Reached_Target=false
var player_Attack_Started=false
var enemy_Attack_Started=false
var player_Attack_Finished=false
var enemy_Attack_Finished=false
var player_response=""
var plrAttackPhase =-1 ### Maybe refactor attack code to use this ###
var double_Attack: bool = false
onready var battleStatus: bool = Globals.battleStatus
onready var playerTurn: bool = Globals.playerTurn

var finished_Drop_Movement: bool = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var Mario = Globals.get_Mario()
onready var enemy = Globals.get_Enemy()

export (PackedScene) var EnemyScene

#var enemy: RigidBody
var player_camera = Camera.new()
var enemy_camera = Camera.new()

var player_Pos: Vector3
var enemy_Pos: Vector3

var lerp_currentTime=0
var lerp_totalTime=3
var lerp_startPos
var lerp_endPos

var time_limited_input_check
var input_timer = 0
var input_timer_max = 0.750


signal get_player_move

signal player_attack

var player_jump_num = -1
var player_jump_max = -1
# Called when the node enters the scene tree for the first time.
func _ready():	
	setupBattleSettings()
	load_players_and_enemies()
	load_and_setup_cameras()
	position_players_and_enemies()
	setupHUD()
	print_debug(Mario.transform.origin)
	
func setupHUD():
	$HUD.startBattle(true)
	yield(get_tree().create_timer(3.0), "timeout")
	print_debug(print_tree_pretty())
	$HUD.update(getPlayerSettings(Mario))
	$HUD.showGUI(0)

func position_players_and_enemies():
	#player.setup()
	Mario.transform.origin.x=$PlayerSpawn.transform.origin.x
	Mario.transform.origin.y=$PlayerSpawn.transform.origin.y
	Mario.transform.origin.z=$PlayerSpawn.transform.origin.z
	
	$EnemySpawn.scale.y=enemy.scale.y
	$EnemySpawn.transform.origin.y=1.8 # Need to find a way to "fall down" 
										 # to Ground Level
	enemy.transform.origin.x=$EnemySpawn.transform.origin.x
	enemy.transform.origin.y=$EnemySpawn.transform.origin.y
	enemy.transform.origin.z=$EnemySpawn.transform.origin.z

	$PlayerSpawn/PlayerAttack_AnimationPlayer.set_current_animation("run_and_jump_up")
	$PlayerSpawn/PlayerAttack_AnimationPlayer.stop(true)

	$EnemySpawn/EnemyAttack_AnimationPlayer.set_current_animation("goomba_attack")
	$EnemySpawn/EnemyAttack_AnimationPlayer.stop(true)
	#player_Pos=player.transform.origin
	#enemy_Pos=enemy.transform.origin
	#player.get_child(0).flip_h=true
	
	Mario.state=Mario.states.IDLE
	Mario.get_child(0).play("idleDown")
	Mario.hflip(true)

func load_and_setup_cameras():
	while typeof(enemy) == TYPE_NIL:
		load_players_and_enemies()
	Mario.add_child(player_camera)
	enemy.add_child(enemy_camera)
	player_camera=Mario.get_child(Mario.get_child_count()-1)
	enemy_camera=enemy.get_child(enemy.get_child_count()-1)
	player_camera.translate(Vector3(0,5,12))
	enemy_camera.translate(Vector3(0,5,9))
	player_camera.current=true
	player_camera.look_at(Mario.transform.origin,Vector3.UP)


func load_players_and_enemies():
	#Mario = Globals.get_Mario()
	#var enemyR=load("res://Goomba.tscn")
	#enemy=enemyR.instance()
	add_child(Mario)
	add_child(enemy)
	


func setupBattleSettings():
	$PlayerSpawn/PlayerAttack_AnimationPlayer.play("run_and_jump_up")
	$PlayerSpawn/PlayerAttack_AnimationPlayer.stop(true)
	
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

func resetCombatants(end_of_turn=true): # if not false, we assume end of turn
	if Globals.playerTurn and end_of_turn==true:
		Globals.playerTurn=false
		Globals.playerGoesFirst=false
		enemy_Attack_Started=true
	else:
		if enemy_Attack_Finished:
			Globals.enemy_turn_finished=true
		if Globals.enemy_turn_finished==true and end_of_turn==true:
			Globals.playerTurn=true
		
	Mario.direction=Vector3.ZERO
	Mario.velocity=Vector3.ZERO
	$PlayerSpawn/PlayerAttack_AnimationPlayer.stop()
	$PlayerSpawn/PlayerAttack_AnimationPlayer.seek(0,true)
	$EnemySpawn/EnemyAttack_AnimationPlayer.stop()
	$EnemySpawn/EnemyAttack_AnimationPlayer.seek(0,true)
	position_players_and_enemies()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.battleStatus ==true:
		if Globals.playerTurn ==true:
			$EnemySpawn/EnemyAttack_AnimationPlayer.stop(true)
			$EnemySpawn/EnemyAttack_AnimationPlayer.seek(0,true)
			emit_signal("get_player_move")
			if player_Attack_Started:
				# player attack
				_on_BattleArena_player_attack(delta)#emit_signal("player_attack", delta)
		else: # Its not players turn
			if enemy_Attack_Started==true:
				enemy_Attack_Finished=false
			$PlayerSpawn/PlayerAttack_AnimationPlayer.set_current_animation("run_and_jump_up")
			$PlayerSpawn/PlayerAttack_AnimationPlayer.stop(true)
			
			if enemy_Attack_Finished:
				$EnemySpawn/EnemyAttack_AnimationPlayer.stop(true)
				$EnemySpawn/EnemyAttack_AnimationPlayer.set_current_animation("goomba_attack")

			if enemy.get_Heart_Points(): # If Enemy is alive
				if enemy.visible==false:
					enemy.show()
				if enemy_Attack_Finished==false:
					if $EnemySpawn/EnemyAttack_AnimationPlayer.is_playing()==false:
						$EnemySpawn/EnemyAttack_AnimationPlayer.play("goomba_attack")
						enemy_Attack_Started=true
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
	if playerWins=="true":
		playerWins = true
	else:
		playerWins = false
	Globals.endBattle(playerWins)


func _on_PlayerAttack_AnimationPlayer_animation_finished(anim_name):
	if anim_name=="run_and_jump_up":
		player_Attack_Finished = true
	else:
		finished_Drop_Movement=true


func _on_AttackInputTimer_timeout():
	time_limited_input_check=false


func _on_BattleArena_get_player_move():
	if player_response=="Jump" and player_Attack_Started!=true:
		player_Attack_Started=true
	else:
		player_response = $HUD.showTurnPanel()


func _on_BattleArena_player_attack(delta):
	var setupVariables = false
	if player_Attack_Finished==false:
		Mario.direction=Vector3.RIGHT
		Mario.state=Mario.states.E
		$PlayerSpawn/PlayerAttack_AnimationPlayer.play("run_and_jump_up")
	if Mario.transform.origin.y>2.5: # if we are off ground level (2.5) then 
									 #  jump
		Mario.state=Mario.states.JUMP
	elif $PlayerSpawn/PlayerAttack_AnimationPlayer.is_playing() and \
		$PlayerSpawn/PlayerAttack_AnimationPlayer.current_animation == "run_and_jump_up":
		Mario.state=Mario.states.E
	else:
		Mario.state=Mario.states.IDLE
		Mario.get_child(0).play("idleDown")
	if player_Attack_Finished:
		var double_Attack
		if !setupVariables:
			double_Attack = false
		time_limited_input_check=true
		while input_timer<input_timer_max: 
			input_timer+=delta
			$HUD/BattlePanel3.popup()
			double_Attack=Mario.checkforAttackInput()
			if double_Attack==false:
				if input_timer>=input_timer_max:
					$HUD/BattlePanel3.hide()
					break
				yield()
			else:
				double_Attack=true
				$HUD/BattlePanel3/GratsMessage.show()
				$HUD/BattlePanel3/NintendoAButton.hide()
				
				break
		input_timer=0
		player_Reached_Target=false

		if double_Attack==false and player_jump_max==-1:
			player_jump_max=1
		#var player_original_position = player.transform.origin
		if double_Attack==true and player_jump_max==-1:
			player_jump_max=2

		#var hitEnemy=false
		var temp_started = null
		if temp_started == null and player_jump_num==-1:
			temp_started=false
			player_jump_num=0
		if input_timer==0:
			if player_jump_num<=player_jump_max:
				temp_started=true
				if !finished_Drop_Movement:
					$PlayerSpawn/PlayerAttack_AnimationPlayer.play("jump_on")
					yield()
				$PlayerSpawn/PlayerAttack_AnimationPlayer.stop(true)
				$PlayerSpawn/PlayerAttack_AnimationPlayer.seek(0, true)
				player_jump_num+=1
				print_debug(player_jump_max)
				if player_jump_max-player_jump_num==1: # we need to update player position if we 
								  # still have another attack to go
					finished_Drop_Movement=false
					yield()
			else:
				$PlayerSpawn/PlayerAttack_AnimationPlayer.stop(true)
				$PlayerSpawn/PlayerAttack_AnimationPlayer.set_current_animation("run_and_jump_up")

		if player_jump_max-player_jump_num==0 and finished_Drop_Movement:
			player_Reached_Target=true
		if player_Reached_Target==true:
			$PlayerSpawn/PlayerAttack_AnimationPlayer.stop(true)
			$PlayerSpawn/PlayerAttack_AnimationPlayer.set_current_animation("run_and_jump_up")
			$HUD/BattlePanel3/Dmg_Info.text=str(player_jump_max)
			$HUD/BattlePanel3.hide()
			Globals.playerGoesFirst=false
			player_Attack_Started=false
			player_Reached_Target=false
			resetCombatants()
	else:
		yield()


func _on_PlayerAttack_AnimationPlayer_animation_changed(old_name, new_name):
	Mario.transform.origin=$PlayerSpawn.transform.origin


func _on_EnemyAttack_AnimationPlayer_animation_changed(old_name, new_name):
	enemy.transform.origin=$EnemySpawn.transform.origin


func _on_EnemyAttack_AnimationPlayer_animation_finished(anim_name):
	print_debug("Enemy attack finished")
	if anim_name=="goomba_attack":
		enemy_Attack_Finished = true
		$EnemySpawn/EnemyAttack_AnimationPlayer.stop(true)
		$EnemySpawn/EnemyAttack_AnimationPlayer.seek(0,true)
	Globals.enemy_turn_finished=true
	enemy_Attack_Finished = true
	enemy_Attack_Started=false
	resetCombatants()



func _on_BattleArena_mario_hit():
	if Globals.playerTurn==false:
		_on_EnemyAttack_AnimationPlayer_animation_finished("goomba_attack")
		Globals.enemy_turn_finished=true
		Globals.playerTurn=true
		resetCombatants()
