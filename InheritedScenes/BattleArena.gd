extends Spatial
signal startBattle(freeAttack)
signal endBattle(playerWins)
signal mario_hit()
signal stop_enemy_attack()


var player_Reached_Target=false
var player_Attack_Started=false
var enemy_Attack_State=0
var player_Attack_Finished=false
var player_response=""
var plrAttackPhase =0 ### Maybe refactor attack code to use this ###
var double_Attack: bool = false
onready var battleStatus: bool = Globals.battleStatus
onready var playerTurn: bool = Globals.playerTurn

var finished_Drop_Movement: bool = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var Mario : Mario= Globals.get_Mario()
onready var enemy = Globals.get_Enemy("Goomba")

export (PackedScene) var EnemyScene

#var enemy: RigidBody
var player_camera = Camera.new()
var enemy_camera = Camera.new()

var player_Pos: Vector3
var enemy_Pos: Vector3


var time_limited_input_check
var input_timer = 0
var input_timer_max = 0.750


signal get_player_move

signal player_attack

var player_jump_num = -1
var player_jump_max = -1

enum enemyAttackStates{
	STARTED = 0,
	IN_PROGRESS = 1,
	FINISHED = 2
}

enum Attack_Phases{FREE_ATTACK, WAITING_FOR_TURN, STARTING, IN_PROGRESS, ACTION_COMMAND, FINISHING}

# Called when the node enters the scene tree for the first time.
func _ready():	
	initVars()
	setupBattleSettings()
	load_players_and_enemies()
	load_and_setup_cameras()
	position_players_and_enemies()
	setupHUD()
	print_debug(Mario.transform.origin)
	
func initVars():
	player_Reached_Target = false
	player_Attack_Started = false
	
	enemy_Attack_State = 0
	
	player_Attack_Finished = false
	
	player_response=""
	
	##plrAttackPhase =-1 ### Maybe refactor attack code to use this ###
	
	double_Attack = false
	battleStatus = Globals.battleStatus
	playerTurn = Globals.playerTurn
	finished_Drop_Movement = false
	
	player_Pos = Vector3.ZERO
	enemy_Pos = Vector3.ZERO
	time_limited_input_check = 0
	input_timer = 0
	input_timer_max = 0.10 # should be 0.1/sec @ 60fps = 6frames
	
func setupHUD():
	$HUD.startBattle(true)
	yield(get_tree().create_timer(3.0), "timeout")
	print_debug(print_tree_pretty())
	self.update_GUI(Mario)
	$HUD.showGUI(0)
	
func update_GUI(Character: Node):
	$HUD.update(self.getPlayerSettings(Character))

func position_players_and_enemies():
	#player.setup()
	Mario.transform.origin.x=$PlayerSpawn.transform.origin.x
	Mario.transform.origin.y=$PlayerSpawn.transform.origin.y
	Mario.transform.origin.z=$PlayerSpawn.transform.origin.z
	
	$EnemySpawn.scale.y=enemy.scale.y
	$EnemySpawn.transform.origin.y=1.8 # Need to find a way to "fall down" 
										 # to Ground Level

	enemy.set_positionV3($EnemySpawn.transform.origin)

	enemy.set_rotation(Vector3.ZERO)

	$PlayerSpawn/PlayerAttack_AnimationPlayer.set_current_animation("run_and_jump_up")
	$PlayerSpawn/PlayerAttack_AnimationPlayer.stop(true)

	$EnemySpawn/EnemyAttack_AnimationPlayer.set_current_animation("goomba_attack")
	$EnemySpawn/EnemyAttack_AnimationPlayer.stop(true)
	
	Mario.state=Mario.states.IDLE
	Mario.get_child(0).play("idleDown")
	Mario.hflip(true)

func load_and_setup_cameras():
#	load_players_and_enemies()
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
	
	if enemy is Goomba:
		enemy as Goomba
	
	add_child(Mario)
	add_child(enemy)
	
	Globals.setPlayerSettings(self.Mario,self.getPlayerSettings(Mario))
	


func setupBattleSettings():
	$PlayerSpawn/PlayerAttack_AnimationPlayer.play("run_and_jump_up")
	$PlayerSpawn/PlayerAttack_AnimationPlayer.stop(true)
	
	if Globals.playerGoesFirst==true:
		_on_BattleArena_startBattle(true)
		Globals.setPlayerGoesFirst(true)
		
	if Globals.playerGoesFirst==false:
		_on_BattleArena_startBattle(false)
		Globals.setPlayerGoesFirst(false)

	
func getPlayerSettings(player: Node):
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

func resetCombatants(end_of_mario_turn=true): # if not false, we assume end of Mario's turn
	initVars()  # we want to effectively reload the battle,
				# but not reload the scene
	if Globals.playerTurn and end_of_mario_turn==true:
		Globals.playerTurn=false
		Globals.playerGoesFirst=false
		enemy_Attack_State==enemyAttackStates.STARTED
		double_Attack=false
	else:
		player_response=""
		if enemy_Attack_State==enemyAttackStates.FINISHED:
			Globals.enemy_turn_finished=true
		if Globals.enemy_turn_finished==true and end_of_mario_turn==true:
			Globals.playerTurn=true
	player_Attack_Started=false
	Mario.direction=Vector3.ZERO
	Mario.velocity=Vector3.ZERO
	$PlayerSpawn/PlayerAttack_AnimationPlayer.stop()
	$PlayerSpawn/PlayerAttack_AnimationPlayer.seek(0,true)
	$EnemySpawn/EnemyAttack_AnimationPlayer.stop()
	$EnemySpawn/EnemyAttack_AnimationPlayer.seek(0,true)
	position_players_and_enemies()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if enemy.get_Heart_Points()>0:
		$HUD/EnemyHP.text="Enemy HP: "+str(enemy.get_Heart_Points())
	if Globals.battleStatus ==true: # if we are in battle
		if Globals.playerTurn == true: # if it's players turn...				
			match plrAttackPhase:
				Attack_Phases.FREE_ATTACK:
					resetCombatants(false)
					var MarioAnimPlayer = $PlayerSpawn/PlayerAttack_AnimationPlayer
					MarioAnimPlayer.current_animation="run_and_jump_up"
					MarioAnimPlayer.seek(MarioAnimPlayer.current_animation_length \
											* 0.5,true)
					MarioAnimPlayer.advance(0)
					Globals.setPlayerGoesFirst(false)
					plrAttackPhase = (Attack_Phases.IN_PROGRESS)
					#MarioAnimPlayer.play("run_and_jump_up")
					$EnemySpawn/EnemyAttack_AnimationPlayer.seek(0,true)
					$EnemySpawn/EnemyAttack_AnimationPlayer.stop(true)
				Attack_Phases.WAITING_FOR_TURN:
					if Globals.playerGoesFirst==true:
						plrAttackPhase=Attack_Phases.FREE_ATTACK
					else:
						emit_signal("get_player_move", delta)
						# ... Make sure enemy position is reset, ...
						$EnemySpawn/EnemyAttack_AnimationPlayer.stop(true)
						$EnemySpawn/EnemyAttack_AnimationPlayer.seek(0,true)
				Attack_Phases.IN_PROGRESS:
					if $PlayerSpawn/PlayerAttack_AnimationPlayer. \
					   current_animation == "jump_on":
						if $PlayerSpawn/PlayerAttack_AnimationPlayer. \
						   current_animation_position==0:
							plrAttackPhase=Attack_Phases.ACTION_COMMAND
				Attack_Phases.ACTION_COMMAND:
					$PlayerSpawn/PlayerAttack_AnimationPlayer.stop(false)
					$PlayerSpawn/PlayerAttack_AnimationPlayer.advance(0)
					input_timer+=delta
					$HUD/AttackMessages.popup()
					if Mario.checkforAttackInput() or input_timer>= \
					   input_timer_max:
						$HUD/AttackMessages/NintendoAButton.hide()
						if input_timer<input_timer_max:
							$HUD/AttackMessages/GratsMessage.show()
							$HUD/AttackMessages/Dmg_Info.text="1"
							double_Attack=true
						plrAttackPhase=Attack_Phases.IN_PROGRESS
						$PlayerSpawn/PlayerAttack_AnimationPlayer.play()
						$PlayerSpawn/PlayerAttack_AnimationPlayer.advance(0)
						$HUD/AttackMessages/Dmg_Info.show()
					else:
#			input_timer+=delta
#			$HUD/AttackMessages.popup()
#			double_Attack=Mario.checkforAttackInput()
#			if double_Attack==false:
#				if input_timer>=input_timer_max:
#					$HUD/AttackMessages.hide()
#					break
#				yield()
						$HUD/AttackMessages/NintendoAButton.show()
				Attack_Phases.FINISHING:
					$HUD/AttackMessages.hide()
					$HUD/AttackMessages/NintendoAButton.hide()
					$HUD/AttackMessages/GratsMessage.hide()
					$PlayerSpawn/PlayerAttack_AnimationPlayer. \
						current_animation="run_and_jump_up"
					$PlayerSpawn/PlayerAttack_AnimationPlayer.seek(0)
					$PlayerSpawn/PlayerAttack_AnimationPlayer.stop(true)
					$PlayerSpawn/PlayerAttack_AnimationPlayer.advance(0)
					if double_Attack==true:
						enemy.receive_damage(1)
					Globals.playerTurn=false
					plrAttackPhase=Attack_Phases.WAITING_FOR_TURN
					resetCombatants(true)
			### if player_Attack_Started: # once player has specified their attack
			###	# start player attack
			###	_on_BattleArena_player_attack(delta, "Jump")
		else: # Its not players turn
			match enemy_Attack_State:
				enemyAttackStates.STARTED:
					enemy_Attack_State=enemyAttackStates.IN_PROGRESS
					if $EnemySpawn/EnemyAttack_AnimationPlayer.is_playing()==false:
						$EnemySpawn/EnemyAttack_AnimationPlayer.play("goomba_attack")
				enemyAttackStates.IN_PROGRESS:
					if not $EnemySpawn/EnemyAttack_AnimationPlayer.is_playing():
						enemy_Attack_State=enemyAttackStates.FINISHED
				enemyAttackStates.FINISHED:
					$EnemySpawn/EnemyAttack_AnimationPlayer.stop(true)
					$EnemySpawn/EnemyAttack_AnimationPlayer.seek(0,true)
					Globals.playerTurn=true
					player_Attack_Started=false
					$HUD._ready()
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
#	if playerWins=="true":
#		playerWins = true
#	else:
#		playerWins = false
	
	Globals.set_Mario(self.Mario)
	self.remove_child(Mario)
	queue_free()
	Globals.endBattle(playerWins, Globals.get_child(0))


func _on_PlayerAttack_AnimationPlayer_animation_finished(anim_name):
	if anim_name=="run_and_jump_up":
		$PlayerSpawn/PlayerAttack_AnimationPlayer.play("jump_on")
	else:
		if double_Attack == false:
			plrAttackPhase=Attack_Phases.FINISHING
		else:
			$PlayerSpawn/PlayerAttack_AnimationPlayer.seek(0)
			$PlayerSpawn/PlayerAttack_AnimationPlayer.stop(true)
			$PlayerSpawn/PlayerAttack_AnimationPlayer.advance(0)
			$PlayerSpawn/PlayerAttack_AnimationPlayer.play()


func _on_AttackInputTimer_timeout():
	time_limited_input_check=false


func _on_BattleArena_get_player_move(delta):
	if player_response=="Jump" and plrAttackPhase==Attack_Phases.WAITING_FOR_TURN:
		plrAttackPhase=Attack_Phases.STARTING
		emit_signal("player_attack", delta, player_response)
		player_response=null
	else:
		player_response = $HUD.showTurnPanel()


func _on_BattleArena_player_attack(delta, playerAttack:String):
	if plrAttackPhase==Attack_Phases.STARTING:
		plrAttackPhase=Attack_Phases.IN_PROGRESS
		if playerAttack=="Jump":
			$PlayerSpawn/PlayerAttack_AnimationPlayer.play("run_and_jump_up")
#	var setupVariables = false
#	if player_Attack_Finished==false:
#		Mario.direction=Vector3.RIGHT
#		Mario.state=Mario.states.E
#	$PlayerSpawn/PlayerAttack_AnimationPlayer.play("run_and_jump_up")
#	if Mario.transform.origin.y>2.5: # if we are off ground level (2.5) then 
#									 #  jump
#		Mario.state=Mario.states.JUMP
#	elif $PlayerSpawn/PlayerAttack_AnimationPlayer.is_playing() and \
#		$PlayerSpawn/PlayerAttack_AnimationPlayer.current_animation == "run_and_jump_up":
#		Mario.state=Mario.states.E
#	else:
#		Mario.state=Mario.states.IDLE
#		Mario.get_child(0).play("idleDown")
#	if player_Attack_Finished:
#		var double_Attack
#		if !setupVariables:
#			double_Attack = false
#		time_limited_input_check=true
#		while input_timer<input_timer_max: 
#			input_timer+=delta
#			$HUD/AttackMessages.popup()
#			double_Attack=Mario.checkforAttackInput()
#			if double_Attack==false:
#				if input_timer>=input_timer_max:
#					$HUD/AttackMessages.hide()
#					break
#				yield()
#			else:
#				double_Attack=true
#				$HUD/AttackMessages/GratsMessage.show()
#				$HUD/AttackMessages/NintendoAButton.hide()
#
#				break
#		input_timer=0
#		player_Reached_Target=false
#
#		if double_Attack==false and player_jump_max==-1:
#			player_jump_max=1
#		#var player_original_position = player.transform.origin
#		if double_Attack==true and player_jump_max==-1:
#			player_jump_max=2
#
#		#var hitEnemy=false
#		var temp_started = null
#		if temp_started == null and player_jump_num==-1:
#			temp_started=false
#			player_jump_num=0
#		if input_timer==0:
#			if player_jump_num<=player_jump_max:
#				temp_started=true
#				if !finished_Drop_Movement:
#					$PlayerSpawn/PlayerAttack_AnimationPlayer.play("jump_on")
#					yield()
#				$PlayerSpawn/PlayerAttack_AnimationPlayer.stop(true)
#				$PlayerSpawn/PlayerAttack_AnimationPlayer.seek(0, true)
#				player_jump_num+=1
#				print_debug(player_jump_max)
#				if player_jump_max-player_jump_num==1: # we need to update player position if we 
#								  # still have another attack to go
#					finished_Drop_Movement=false
#					yield()
#			else:
#				$PlayerSpawn/PlayerAttack_AnimationPlayer.stop(true)
#				$PlayerSpawn/PlayerAttack_AnimationPlayer.set_current_animation("run_and_jump_up")
#
#		if player_jump_max-player_jump_num==0 and finished_Drop_Movement:
#			player_Reached_Target=true
#		if player_Reached_Target==true:
#			$PlayerSpawn/PlayerAttack_AnimationPlayer.stop(true)
#			$PlayerSpawn/PlayerAttack_AnimationPlayer.set_current_animation("run_and_jump_up")
#			$HUD/AttackMessages/Dmg_Info.text=str(player_jump_max)
#			$HUD/AttackMessages.hide()
#			Globals.playerGoesFirst=false
#			player_Attack_Started=false
#			player_Reached_Target=false
#			resetCombatants()
#	else:
#		yield()


func _on_PlayerAttack_AnimationPlayer_animation_changed(old_name, new_name):
	Mario.transform.origin=$PlayerSpawn.transform.origin


func _on_EnemyAttack_AnimationPlayer_animation_changed(old_name, new_name):
	enemy.transform.origin=$EnemySpawn.transform.origin


func _on_EnemyAttack_AnimationPlayer_animation_finished(anim_name):
	print_debug("Enemy attack finished")
	if anim_name=="goomba_attack":
		enemy_Attack_State==enemyAttackStates.FINISHED
		$EnemySpawn/EnemyAttack_AnimationPlayer.stop(true)
		$EnemySpawn/EnemyAttack_AnimationPlayer.seek(0,true)
	Globals.enemy_turn_finished=true
	Globals.playerTurn == true
	enemy_Attack_State==enemyAttackStates.FINISHED
	resetCombatants(false)



func _on_BattleArena_mario_hit():
	self.update_GUI(self.Mario)#getPlayerSettings(self.Mario))
	if Globals.playerTurn==false:
		_on_EnemyAttack_AnimationPlayer_animation_finished("goomba_attack")
		Globals.enemy_turn_finished=true
		Globals.playerTurn=true
		resetCombatants(false)


func _on_BattleArena_stop_enemy_attack() -> void:
	enemy_Attack_State==enemyAttackStates.FINISHED
	$EnemySpawn/EnemyAttack_AnimationPlayer.stop(true)
	$EnemySpawn/EnemyAttack_AnimationPlayer.seek(0,true)
	resetCombatants(false)
