extends Node
@export var score_text : String = ""
var RESET_TIME = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$FinalScore.text = score_text
	# Create a final score timer
	$BurnTimer.start(RESET_TIME)
	$BurnBar.max_value = RESET_TIME
	$BurnBar.value = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$BurnBar.value = $BurnBar.max_value - $BurnTimer.time_left
	$BurnBar.modulate.r8 = 255 * ($BurnBar.max_value - $BurnTimer.time_left) / $BurnBar.max_value
	pass
