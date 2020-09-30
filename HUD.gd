extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func update_hp(HP):
	$HPLabel.text = "HP: "+str(HP)+"/10"

func update_petals(petals):
	$FlowersLabel.text = "P: "+str(petals)+"/5"

func update_coins(coins):
	$CoinLabel.text = "C: "+str(coins)+"/56"
	
func update_stars(stars):
	$StarsLabel.text = "S: "+str(stars)+"/63"



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
