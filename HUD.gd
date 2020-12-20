extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var response = ""

var doneOnce = false


onready var HP_idx = Globals.MarioStats.HEART_POINTS
onready var FP_idx = Globals.MarioStats.FLOWER_POINTS
onready var Coin_idx = Globals.MarioStats.COINS
onready var Star_idx = Globals.MarioStats.STAR_POINTS

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
	update_flowers(playerSettings[FP_idx])
	update_coins(playerSettings[Coin_idx])
	update_stars(playerSettings[Star_idx])

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
		$BattlePanel.popup()
		yield(get_tree().create_timer(3.0), "timeout")
		$BattlePanel.hide()

func showTurnPanel():
	if $BattlePanel.visible==false:
		$BattlePanel2.popup()
		$BattlePanel2/abilityList.focus_mode=2
		$BattlePanel2/abilityList.grab_focus()
		showGUI(3,true)
		
	if response!="":
		$BattlePanel2/abilityList.focus_mode=0
		$BattlePanel2/abilityList.release_focus()
		$BattlePanel2.hide()
		hideGUI()
	return response

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_abilityList_gui_input(_event):
	var input_valid = false
	if Input.is_action_pressed("ui_down"):
		input_valid=true
		for x in $BattlePanel2/abilityList.get_item_count():
			if $BattlePanel2/abilityList.is_selected(x):
				if x+1 > $BattlePanel2/abilityList.get_item_count():
					$BattlePanel2/abilityList.select(0)
					break
				else:
					$BattlePanel2/abilityList.select(x+1)
	if Input.is_action_pressed("jump") or Input.is_action_pressed("ui_accept"):
		input_valid=true
		var selected_item_idx = -1
		for x in $BattlePanel2/abilityList.get_item_count():
			if $BattlePanel2/abilityList.is_selected(x):
				selected_item_idx=x
				response=$BattlePanel2/abilityList.get_item_text(x)
				break
	if Input.is_action_pressed("ui_focus_next"):
		input_valid=false
		showGUI()
	if input_valid==false:
		if $BattlePanel2.visible==true:
			$BattlePanel2/abilityList.focus_mode=2
			$BattlePanel2/abilityList.grab_focus()
			response=""


func _on_BattlePanel3_about_to_show():
	$BattlePanel3/Dmg_Info.hide()
	$BattlePanel3/NintendoAButton.focus_mode=2
	$BattlePanel3/NintendoAButton.grab_focus()

func _on_BattlePanel3_popup_hide():
	$BattlePanel3/NintendoAButton.focus_mode=0
	$BattlePanel3/NintendoAButton.release_focus()
	 # Replace with function body.


func _on_NintendoAButton_gui_input(_event):
	if Input.is_action_pressed("jump"):
		$BattlePanel3/NintendoAButton.emit_signal("pressed")
	 # Replace with function body.


func _on_NintendoAButton_pressed():
	get_parent().doubleAttack=true
	$BattlePanel3/GratsMessage.show()
	 # Replace with function body.


func _on_Goombah_body_entered(body):
	$BattlePanel3/Dmg_Info.show()
	$BattlePanel3/DMG_AnimationPlayer.play("Dmg_Float")


func _on_DMG_AnimationPlayer_animation_finished(anim_name):
	$BattlePanel3/Dmg_Info.hide()
