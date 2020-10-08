extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var response = ""

var doneOnce = false

func update_hp(HP):
	$HPLabel.text = "HP: "+str(HP)+"/"+str(Globals.max_Heart_Points)

func update_flowers(flowers):
	$FlowersLabel.text = "FP: "+str(flowers)+"/"+str(Globals.max_Flower_Points)

func update_coins(coins):
	$CoinLabel.text = "C: "+str(coins)+"/"+str(Globals.max_Coins)
	
func update_stars(stars):
	$StarsLabel.text = "S: "+str(stars)+"/"+str(Globals.max_Star_Points)

func update(playerSettings: Array):
	update_hp(playerSettings[Globals.MarioStats.HEART_POINTS])
	update_flowers(playerSettings[Globals.MarioStats.FLOWER_POINTS])
	update_coins(playerSettings[Globals.MarioStats.COINS])
	update_stars(playerSettings[Globals.MarioStats.STAR_POINTS])

func showGUI(time = 3.0, forever = false):
	$HPLabel.show()
	$FlowersLabel.show()
	$CoinLabel.show()
	$StarsLabel.show()
	if forever == false:
		yield(get_tree().create_timer(time), "timeout")
		$HPLabel.hide()
		$FlowersLabel.hide()
		$CoinLabel.hide()
		$StarsLabel.hide()

func hideGUI():
	$HPLabel.hide()
	$FlowersLabel.hide()
	$CoinLabel.hide()
	$StarsLabel.hide()


func startBattle(playerFirst: bool):
	if playerFirst:
		$BattlePanel.show()
		yield(get_tree().create_timer(3.0), "timeout")
		$BattlePanel.hide()

func showTurnPanel():
	$BattlePanel2.show()
	while response=="":
		yield(get_tree().create_timer(0.5), "timeout")
	$BattlePanel2.hide()
	$BattlePanel2.set_process(false)
	return response

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_focus_next") and doneOnce==false:
		doneOnce = true
		showGUI()
	pass
