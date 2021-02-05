extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var response = ""

var doneOnce = false

var cHP = null
var cFP = null
var cC = null
var cS = null

onready var HP_idx = Globals.MarioStats.HEART_POINTS
onready var FP_idx = Globals.MarioStats.FLOWER_POINTS
onready var Coin_idx = Globals.MarioStats.COINS
onready var Star_idx = Globals.MarioStats.STAR_POINTS

var iRewardProcessTimeFinish: bool = true

func update_hp(HP):
	$HP_Panel/HPLabel.text = "HP: "+str(HP)+"/"+str(Globals.max_Heart_Points)

func update_flowers(flowers):
	$PP_Panel/FlowersLabel.text = ""+str(flowers)+"/"+str(Globals.max_Flower_Points)

func update_coins(coins):
	$SnC_Panel/CoinLabel.text = "C: "+str(coins)+"/"+str(Globals.max_Coins)
	
func update_stars(stars):
	$SnC_Panel/StarsLabel.text = "S: "+str(stars)+"/"+str(Globals.max_Star_Points)

func update(playerSettings: Array):
	update_hp(playerSettings[HP_idx])
	if cHP != null and cHP != playerSettings[HP_idx]:
		showGUI()
	update_flowers(playerSettings[FP_idx])
	if cFP != null and cFP != playerSettings[FP_idx]:
		showGUI()
	update_coins(playerSettings[Coin_idx])
	if cC != null and cC != playerSettings[Coin_idx]:
		showGUI()
	update_stars(playerSettings[Star_idx])
	if cS != null and cS != playerSettings[Star_idx]:
		showGUI()
	if cHP == null:
		cHP = playerSettings[HP_idx]
	if cFP == null:
		cFP = playerSettings[FP_idx]
	if cC == null:
		cC = playerSettings[Coin_idx]
	if cS == null:
		cS = playerSettings[Star_idx]

func showGUI(time = 3.0, forever = false):
	$HP_Panel.show()
	$PP_Panel.show()
	$SnC_Panel.show()
	if forever == false:
		yield(get_tree().create_timer(time), "timeout")
		hideGUI()

func hideGUI():
	$HP_Panel.hide()
	$PP_Panel.hide()
	$SnC_Panel.hide()

func startBattle(playerFirst: bool):
	if playerFirst:
		$TurnPanel.popup()
		yield(get_tree().create_timer(3.0), "timeout")
		$TurnPanel.hide()

func showTurnPanel():
	if $TurnPanel.visible==false:
		$TurnPanel.popup()
		$TurnPanel/abilityList.focus_mode=2
		$TurnPanel/abilityList.grab_focus()
		showGUI(3,false)
		
	if response!="":
		doneOnce=true
		$TurnPanel/abilityList.focus_mode=0
		$TurnPanel/abilityList.release_focus()
		$TurnPanel.hide()
		hideGUI()
	return response

# Called when the node enters the scene tree for the first time.
func _ready():
	response=""
	setupUI()
	
func setupUI():
	setupUI_AttackMessages()
	setupUI_IntroPanel()

func setupUI_AttackMessages():
	$AttackMessages.hide()
	$AttackMessages/GratsMessage.hide()
	$AttackMessages/NintendoAButton.hide()
	$AttackMessages/Dmg_Info.hide()

func setupUI_IntroPanel():
	$IntroPanel.hide()
	
func RewardCount(stat: int, amount: int):
	showGUI(30)
	for x in amount:
		if iRewardProcessTimeFinish == true:
			match stat:
				HP_idx:
					cHP=cHP+1
					update_hp(cHP)
				FP_idx:
					cFP=cFP+1
					update_hp(cFP)
				Coin_idx:
					cC=cC+1
					update_hp(cC)
				Star_idx:
					cS=cS+1
					update_hp(cS)
			$RewardTimer.start()
			iRewardProcessTimeFinish=false

func _process(delta: float) -> void:
	update(get_parent().getPlayerSettings(get_parent().Mario))

func _on_abilityList_gui_input(_event):
	var input_valid = false
	if Input.is_action_pressed("ui_down"):
		input_valid=true
		for x in $TurnPanel/abilityList.get_item_count():
			if $TurnPanel/abilityList.is_selected(x):
				if x+1 > $TurnPanel/abilityList.get_item_count():
					$TurnPanel/abilityList.select(0)
					break
				else:
					$TurnPanel/abilityList.select(x+1)
	if Input.is_action_pressed("jump") or Input.is_action_pressed("ui_accept"):
		input_valid=true
		var selected_item_idx = -1
		for x in $TurnPanel/abilityList.get_item_count():
			if $TurnPanel/abilityList.is_selected(x):
				selected_item_idx=x
				response=$TurnPanel/abilityList.get_item_text(x)
				break
	if Input.is_action_pressed("ui_focus_next"):
		input_valid=false
		showGUI()
	if input_valid==false:
		if $TurnPanel.visible==true:
			$TurnPanel/abilityList.focus_mode=2
			$TurnPanel/abilityList.grab_focus()
			response=""


func _on_BattlePanel3_about_to_show():
	$AttackMessages/Dmg_Info.hide()
	$AttackMessages/NintendoAButton.focus_mode=2
	$AttackMessages/NintendoAButton.grab_focus()

func _on_BattlePanel3_popup_hide():
	$AttackMessages/NintendoAButton.focus_mode=0
	$AttackMessages/NintendoAButton.release_focus()
	 # Replace with function body.


func _on_NintendoAButton_gui_input(_event):
	if Input.is_action_pressed("jump"):
		$AttackMessages/NintendoAButton.emit_signal("pressed")
	 # Replace with function body.


func _on_NintendoAButton_pressed():
	get_parent().doubleAttack=true
	$AttackMessages/GratsMessage.show()
	 # Replace with function body.


func _on_Goombah_body_entered(body):
	$AttackMessages/Dmg_Info.show()
	$AttackMessages/DMG_AnimationPlayer.play("Dmg_Float")


func _on_DMG_AnimationPlayer_animation_finished(anim_name):
	$AttackMessages/Dmg_Info.hide()


func _on_RewardTimer_timeout() -> void:
	iRewardProcessTimeFinish=true
	pass # Replace with function body.
