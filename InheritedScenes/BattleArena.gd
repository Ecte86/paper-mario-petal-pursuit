extends Spatial
signal startBattle(freeAttack)
signal endBattle(playerWins)


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
	
	enemy.transform.origin.x=$EnemySpawn.transform.origin.x
	enemy.transform.origin.y=$EnemySpawn.transform.origin.y
	enemy.transform.origin.z=$EnemySpawn.transform.origin.z

	$PlayerSpawn/PlayerAttack_AnimationPlayer.set_current_animation("run_and_jump_up")
	$PlayerSpawn/PlayerAttack_AnimationPlayer.stop(true)

	#player_Pos=player.transform.origin
	#enemy_Pos=enemy.transform.origin
	#player.get_child(0).flip_h=true
	
	Mario.state=Mario.states.IGNORE
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
	else:
		if Globals.enemy_turn_finished==true and end_of_turn==true:
			Globals.playerTurn=true
		
	Mario.direction=Vector3.ZERO
	Mario.velocity=Vector3.ZERO
	$PlayerSpawn/PlayerAttack_AnimationPlayer.stop()
	$PlayerSpawn/PlayerAttack_AnimationPlayer.seek(0,true)
	position_players_and_enemies()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.battleStatus ==true:
		if Globals.playerTurn ==true:
			emit_signal("get_player_move")
			if player_Attack_Started:
				# player attack
				_on_BattleArena_player_attack(delta)#emit_signal("player_attack", delta)
		else: # Its npt players turn
			$PlayerSpawn/PlayerAttack_AnimationPlayer.set_current_animation("run_and_jump_up")
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
	if playerWins=="true":
		playerWins = true
	else:
		playerWins = false
	Globals.endBattle(playerWins)
