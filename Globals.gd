extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var hp=10
var petals=5
var coins=56
var stars=63
var playerGoesFirst = null
var playerTurn=null
var battleStatus=0

<<<<<<< Updated upstream
=======
var current_scene = null

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
	
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

>>>>>>> Stashed changes
func setPlayerGoesFirst(value: bool):
	playerTurn=value
	playerGoesFirst=value

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func startBattle(playersTurn: bool):
	setPlayerGoesFirst(playersTurn)
	battleStatus=1

func endBattle(playerWins: bool):
	battleStatus=0
	playerGoesFirst=null
	playerTurn=null
	if playerWins:
		get_tree().change_scene("res://Main.tscn")
	else:
		# insert lose msg
		get_tree().quit()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
