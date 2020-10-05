extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func update_hp(HP):
	$HPLabel.text = "HP: "+str(HP)+"/"+str(Globals.max_Heart_Points)

func update_petals(petals):
	$FlowersLabel.text = "FP: "+str(petals)+"/"+str(Globals.max_Flower_Points)

func update_coins(coins):
	$CoinLabel.text = "C: "+str(coins)+"/"+str(Globals.max_Coins)
	
func update_stars(stars):
	$StarsLabel.text = "S: "+str(stars)+"/"+str(Globals.max_Star_Points)



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
