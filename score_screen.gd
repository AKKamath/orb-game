extends Node
@export var RESET_TIME = 50
var style
var difficulty

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create the final score timer
	$BurnTimer.start(RESET_TIME)
	$BurnBar.max_value = RESET_TIME
	$BurnBar.value = 0

func setup_score(score : int, gameStyle : Util.STYLE, gameDiff : Util.DIFF, ROWS : int, ROUNDS : int, scoredSteps : int):
	var avg_score = 0.0
	style = gameStyle
	difficulty = gameDiff
	match gameStyle:
		Util.STYLE.CLASSIC:
			avg_score = float(score) / float(ROUNDS * ROWS)
		Util.STYLE.ENDLESS:
			if(scoredSteps):
				avg_score = float(score) / float(scoredSteps) / float(ROWS)
			else:
				avg_score = 0
		Util.STYLE.PERFECT:
			# Arbitrary. Let 12 perfect rounds be the best
			avg_score = float(scoredSteps) / 12.0
	# Output flavor text based on average score
	if(avg_score >= 1.0):
		$UIElems/FinalScore.text = "PERFECT!!"
	elif(avg_score >= 7.0/8.0):
		$UIElems/FinalScore.text = "Great!"
	elif(avg_score >= 3.0/4.0):
		$UIElems/FinalScore.text = "Good"
	elif(avg_score >= 0.5):
		$UIElems/FinalScore.text = "Nice"
	else:
		$UIElems/FinalScore.text = "Terrible"
	$UIElems/FinalScore.modulate = Util.TYPE_COLOR[0].lerp(Util.TYPE_COLOR[2], avg_score)
	match gameStyle:
		Util.STYLE.CLASSIC:
			$UIElems/FinalScore.text += "\nScore: " + str(score) + " / " + str(ROUNDS * ROWS)
		Util.STYLE.ENDLESS:
			if scoredSteps:
				$UIElems/FinalScore.text += "\n Avg score: " + str(score / scoredSteps) + " / " + str(ROWS)
			else:
				$UIElems/FinalScore.text += "\n Avg score: 0 / " + str(ROWS)
		Util.STYLE.PERFECT:
			$UIElems/FinalScore.text += "\n Perfect rounds: " + str(scoredSteps)
	$UIElems/FinalScore.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$BurnBar.value = $BurnBar.max_value - $BurnTimer.time_left
	$BurnBar.modulate.r8 = 255 * ($BurnBar.max_value - $BurnTimer.time_left) / $BurnBar.max_value
	pass


func _on_continue_pressed() -> void:
	var root = get_parent()
	# Remove the title screen
	var level = root.get_node("ScoreScreen")
	root.remove_child(level)
	level.call_deferred("free")

	# Go to Title screen
	var next_level_resource = load("res://title.tscn")
	var next_level = next_level_resource.instantiate()
	root.add_child(next_level)


func _on_replay_pressed() -> void:
	var root = get_parent()
	# Remove the title screen
	var level = root.get_node("ScoreScreen")
	root.remove_child(level)
	level.call_deferred("free")

	# Go to game
	var next_level_resource = load("res://game.tscn")
	var next_level = next_level_resource.instantiate()
	match difficulty:
		Util.DIFF.EASY:
			next_level.BURN_TIME = 15
		Util.DIFF.NORMAL:
			next_level.BURN_TIME = 10
		Util.DIFF.HARD:
			next_level.BURN_TIME = 5
	
	next_level.gameStyle = style
	next_level.difficulty = difficulty
	root.add_child(next_level)
