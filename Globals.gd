extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#var hp=10
#var petals=5
#var coins=56
#var stars=63
var playerGoesFirst = null
var playerTurn=null
onready var battleStatus=false

export (bool) var FAKE_SHADOW = false

enum MarioStats{
	NAME = 0,
	HEART_POINTS = 1,
	FLOWER_POINTS = 2,
	BADGE_POINTS = 3,
	STAR_POINTS = 4,
	LEVEL = 5,
	PETAL_POWER = 6,
	COINS = 7
}

enum EnemyHP {
	Goomba = 3
}

export(int) var max_Heart_Points = 10 # Maximum Heart Points == Hit Points == Life

export (int) var max_Flower_Points = 10 # Max FP = Mana

export (int) var max_Badge_Points = 10 # 

export (int) var max_Star_Points = 99 # XP

export (int) var max_Level = 10

export (int) var max_Petal_Power = 7

export (int) var max_Coins = 100

export (bool) var enemy_turn_finished = false

export (PackedScene) var MarioScene = preload("res://Mario.tscn")

var node_Mario: Node = null #=MarioScene.instance()# : Node
var node_MarioDupe: Node

var node_Enemy: Node
var node_EnemyDupe: Node
var Enemy_Name: String
var Enemy_idx: int

var last_battle_reward = null

var last_battle_winner = 0

var current_scene = null

enum BattleWinner {NONE, MARIO, ENEMY}

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	load_Mario()
	self.node_Mario.setHeartPoints(8)
	#Mario=

func load_Mario():
	var PlayerScene
	PlayerScene=load("res://Mario.tscn")
	self.set_Mario(PlayerScene.instance())
	#Mario = PlayerScene.instance()

func get_Enemy(Enemy_Name):
	node_EnemyDupe=self.get_child(self.get_child_count()-1).duplicate()
	var children=self.get_children()
	var idx=0
	for child in children:
		if child.name==Enemy_Name:
			self.remove_child(self.get_child(idx))
		idx+=1
	return node_EnemyDupe

func set_Enemy(theEnemyNode):
	Enemy_Name=theEnemyNode.name
	self.add_child_below_node(node_Mario,theEnemyNode.duplicate())
	node_Enemy=self.get_child(self.get_child_count()-1)
	Enemy_idx=self.get_child_count()-1
	
	
func get_Mario():
	if node_Mario == null:
		load_Mario()
	node_MarioDupe=node_Mario.duplicate()
	self.remove_child(self.get_child(0))
	return node_MarioDupe

func set_Mario(node_Modified_Mario):
	if self.get_child(0) != null:
		self.remove_child(self.get_child(0))
	self.add_child_below_node(self,node_Modified_Mario.duplicate())
	node_Mario=self.get_child(0)


func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)
	#call("_deferred_goto_scene", path)


func _deferred_goto_scene(path):
	
	# Define root
	var root = get_tree().get_root()
	
	# Ensure that current_scene isn't null
	if current_scene == null:
		current_scene = root.get_child(root.get_child_count() - 1)
	
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)

func _deferred_goto_provided_scene(theScene: NodePath):
	# It is now safe to remove the current scene
	yield()
	current_scene.free()

	# Instance the new scene.
	#current_scene = s.instance()

	# Add it to the active scene, as child of root.
	#get_tree().get_root().add_child(theScene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(get_node(theScene))

func setPlayerGoesFirst(value: bool):
	playerTurn=value
	playerGoesFirst=value


	
#func startBattle(playersTurn: bool):

func endBattle(playerWins: bool, mario):
	battleStatus=false
	playerGoesFirst=null
	playerTurn=null
	if playerWins:
		print("MARIO WINS")
		last_battle_winner = BattleWinner.MARIO
		#Input.action_press("jump")
		#Input.action_release("jump")
		node_Mario.setStarPoints(node_Mario.getStarPoints()+20)
		set_last_battle_reward(3,20)
		#get_tree().quit()#get_tree().change_scene("res://Main.tscn")
	else:
		# insert lose msg
		print("OH NO MARIO LOSES :(")
		last_battle_winner = BattleWinner.ENEMY
		
	get_tree().change_scene("res://Main.tscn")
	#_deferred_goto_scene("res://Main.tscn")
	
	

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
	
func set_last_battle_reward(stat: int, amount: int):
	last_battle_reward=[]
	for x in last_battle_reward:
		if x == stat:
			last_battle_reward[x] = amount
		else:
			last_battle_reward[x]=null
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
#	if Mario==null:
#		breakpoint
	pass
