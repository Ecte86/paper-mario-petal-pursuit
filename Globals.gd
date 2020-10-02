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
