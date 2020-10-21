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
var battleStatus =false

var battle_just_won: bool = false

var marioFile = ResourceLoader.load("res://Mario.tscn")
var marioData = marioFile.instance()

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
enum EnemyTypes{
	Goomba = 0
}

enum EnemyHP {
	Goomba = 2
}

export(int) var Heart_Points = 10 # Heart Points == Hit Points == Life
export(int) var max_Heart_Points = 10 # Maximum Heart Points == Hit Points == Life

export(int) var Flower_Points = 10
export (int) var max_Flower_Points = 10 # Max FP = Mana

export (int) var Badge_Points = 0 # 
export (int) var max_Badge_Points = 10 # 

export (int) var Star_Points = 99 # XP
export (int) var max_Star_Points = 99 # XP

export (int) var Level = 1
export (int) var max_Level = 10

export (int) var Petal_Power = 0
export (int) var max_Petal_Power = 7

export (int) var Coins = 100
export (int) var max_Coins = 100

export (bool) var enemy_turn_finished= false

var enemiesArray=[]

var current_scene = null

func generate_enemyID(type: int):
	randomize()
	match type:
		0:
			var ID="Goom"+str(rand_range(1000,9000))
			enemiesArray.append(ID)
			return ID

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	load_and_populate_mario_stats()
	
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

func load_and_populate_mario_stats():
	var file = File.new()
	file.open("res://Data Files/Mario.json", file.READ)
	var json = file.get_as_text()
	var json_result = JSON.parse(json).result
	file.close()
	if typeof(json_result) == TYPE_ARRAY:
		Heart_Points=json_result[0]["Value"]
		max_Heart_Points=json_result[1]["Value"]
		Flower_Points = json_result[2]["Value"]
		max_Flower_Points = json_result[3]["Value"]
		Badge_Points = json_result[4]["Value"]
		max_Badge_Points = json_result[5]["Value"]
		Star_Points = json_result[6]["Value"]
		max_Star_Points = json_result[7]["Value"]
		Level = json_result[8]["Value"]
		max_Level = json_result[9]["Value"]
		Petal_Power = json_result[10]["Value"]
		max_Petal_Power = json_result[11]["Value"]
		Coins = json_result[12]["Value"]
		max_Coins = json_result[13]["Value"]
	else:
		push_error("Unexpected results.")
	

func _deferred_goto_scene(path):
	var root = get_tree().get_root()
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

func endBattle(playerWins: bool):
	battleStatus=false
	playerGoesFirst=null
	playerTurn=null
	if playerWins:
		battle_just_won=true
		goto_scene("res://Main.tscn")
	else:
		# insert lose msg
		get_tree().quit()
	

func get_damage(name_of_creature): # mob or player
	match name_of_creature:
		"Mario":
			return 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _processUserInput(delta): # If user presses tab, show the stats GUI 
	# TODO: add a check for the equivalent button on a Nintendo controller
	if Input.is_action_just_pressed("ui_focus_next"):
		return true
	else:
		return false
