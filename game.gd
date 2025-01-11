extends Node
@export var orbObj : PackedScene

enum STYLE {
	CLASSIC = 0,
	ENDLESS = 1,
	PERFECT = 2,
}

const ROWS = 8
const COLS = 10

var BURN_TIME = 10
var RESET_TIME = 50
var ROUNDS = 10

var orbDict = {}
var curOrb = null

# Game scene view
var box
var offset
var radius

# Game variables
var score = 0
var steps = 0
var scoredSteps = 0
var perfectSteps = 0
var game_running = false
var gameStyle = STYLE.CLASSIC

# Calculate the on-screen position of a given (x, y) orb inside box
func calc_pos(x : int, y : int):
	return Vector2(x * box.x / COLS + radius, 
				y * box.y / ROWS + radius + ((x + steps) % 2) * radius)

# Connect the orb to its neighbors
func connect_orbs(newOrb):
	var i = newOrb.index.x
	var j = newOrb.index.y
	if(i > 0):
		#print("Connecting ", Vector2i(i - 1, j), " to ", newOrb.index)
		newOrb.connect_orb(orbDict[Vector2i(i - 1, j)])
		if(((i + steps) % 2) == 1):
			if(j < ROWS - 1):
				newOrb.connect_orb(orbDict[Vector2i(i - 1, j + 1)])
		elif (j > 0):
			newOrb.connect_orb(orbDict[Vector2i(i - 1, j - 1)])

# Generate a new column of orbs at column col
func create_new_col(col: int, move : bool = false, burnCount : int = 0):
	var burnedIndices = []
	if burnCount:
		burnedIndices = range(ROWS)
		burnedIndices.shuffle()
		burnedIndices = burnedIndices.slice(0, burnCount)
	
	var i = col
	for j in range(ROWS):
		var newOrb = orbObj.instantiate()
		# Initialize orb data
		var pos = calc_pos(i, j) + offset
		newOrb.dest = pos
		if !move:
			newOrb.position = pos
		else:
			newOrb.position = Vector2(0, pos.y)
		newOrb.radius = radius
		newOrb.type = randi() % 3
		if(j in burnedIndices):
			newOrb.type = 2
			newOrb.burned = true
		newOrb.index = Vector2(i, j)
		newOrb.clicked.connect(_on_orb_clicked.bind())
		# Add orb to our database
		orbDict[newOrb.index] = newOrb
		add_child(newOrb)
		#print("Added ", newOrb.index)
		# Connect to neighboring orbs
		connect_orbs(newOrb)
			#orbDict[Vector2i(i - 1, j)].connect_orb(newOrb)
		#if abs(index.x - curOrb.x) == 1 and \
		#		((index.y == curOrb.y) or \
		#		(index.y + (index.x % 2) == curOrb.y + (curOrb.x % 2))):
		
func get_orb_nbors(index : Vector2i):
	var x = index.x
	var y = index.y
	var neighbors = []
	if(x > 0):
		neighbors.append(orbDict[Vector2i(x - 1, y)])
		if(((x + steps) % 2) == 1):
			if(y < ROWS - 1):
				neighbors.append(orbDict[Vector2i(x - 1, y + 1)])
		elif y > 0:
			neighbors.append(orbDict[Vector2i(x - 1, y - 1)])
	if(x < COLS - 1):
		neighbors.append(orbDict[Vector2i(x + 1, y)])
		if(((x + steps) % 2) == 1):
			if(y < ROWS - 1):
				neighbors.append(orbDict[Vector2i(x + 1, y + 1)])
		elif y > 0:
			neighbors.append(orbDict[Vector2i(x + 1, y - 1)])
	return neighbors

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	box = get_viewport().size * 0.85
	offset = get_viewport().size * 0.15 / 2
	radius = min(box.x / COLS, box.y / ROWS) / 2
	offset.y = radius / 2
	$ScoreBar.size.y = radius / 2
	
	if(gameStyle != STYLE.CLASSIC):
		$ScoreBar.hide()
	
	# Reset vars
	score = 0
	steps = 0
	scoredSteps = 0
	perfectSteps = 0
	curOrb = null
	
	# Generate new orbs
	for i in range(COLS):
		create_new_col(i)
	
	$FinalScore.hide()
	# Reset UI elements
	$Button.text = "Stop"
	$UI.get_node("Score").text = ""
	$BurnTimer.start(BURN_TIME)
	$BurnBar.max_value = BURN_TIME
	$BurnBar.value = 0
	$ScoreBar.max_value = ROUNDS
	$ScoreBar.value = 0
	
	game_running = true
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$BurnBar.value = $BurnBar.max_value - $BurnTimer.time_left
	$BurnBar.modulate.r8 = 255 * ($BurnBar.max_value - $BurnTimer.time_left) / $BurnBar.max_value
	pass

func _on_orb_clicked(index: Vector2i, clicked: bool, dragged : bool) -> void:
	print(curOrb, index, clicked, dragged)
	if curOrb == null and clicked and !dragged:
		curOrb = index
		orbDict[curOrb].highlight(true)
		return
	elif curOrb == index and !clicked:
		orbDict[curOrb].highlight(false)
		curOrb = null
		return
		
	if curOrb == null:
		return
	else:
		if abs(index.x - curOrb.x) == 1 and \
				((index.y == curOrb.y) or \
				(index.y + ((index.x + steps) % 2) == curOrb.y + ((curOrb.x + steps) % 2))):
			if(!orbDict[curOrb].can_swap(orbDict[index])):
				if !dragged:
					orbDict[curOrb].highlight(false)
					curOrb = index
					orbDict[curOrb].highlight(true)
				return
			# Disconnect neighbors
			var nbors = get_orb_nbors(curOrb)
			for orb in nbors:
				orb.disconnect_orb(orbDict[curOrb])
				
			nbors = get_orb_nbors(index)
			for orb in nbors:
				orb.disconnect_orb(orbDict[index])
				
			orbDict[curOrb].swap(orbDict[index])
			
			# Swap
			var temp = orbDict[curOrb]
			orbDict[curOrb] = orbDict[index]
			orbDict[index] = temp
			
			# Connect new neighbors
			nbors = get_orb_nbors(curOrb)
			for orb in nbors:
				if(orb.index.x > curOrb.x):
					orb.connect_orb(orbDict[curOrb])
				else:
					orbDict[curOrb].connect_orb(orb)
				
			nbors = get_orb_nbors(index)
			for orb in nbors:
				if(orb.index.x > index.x):
					orb.connect_orb(orbDict[index])
				else:
					orbDict[index].connect_orb(orb)
					
			if !dragged:
				curOrb = null
			else:
				curOrb = index
				orbDict[curOrb].highlight(true)
		elif !dragged:
			orbDict[curOrb].highlight(false)
			curOrb = index
			orbDict[curOrb].highlight(true)
	pass # Replace with function body.

func game_end():
	$UI.get_node("Score").text = ""
	$Button.text = "Start"
	$ScoreIndicator.reset()
	# Delete all orbs
	for orb in orbDict:
		orbDict[orb].disconnect_all()
		orbDict[orb].queue_free()
	orbDict.clear()
	# Set game running to false, for reset
	game_running = false
	
	var avg_score = 0.0
	match gameStyle:
		STYLE.CLASSIC:
			avg_score = float(score) / float(ROUNDS * ROWS)
		STYLE.ENDLESS:
			if(scoredSteps):
				avg_score = float(score) / float(scoredSteps) / float(ROWS)
			else:
				avg_score = 0
		STYLE.PERFECT:
			# Arbitrary. Let 12 perfect rounds be the best
			avg_score = float(scoredSteps) / 12.0
	# Output flavor text based on average score
	if(avg_score >= 1.0):
		$FinalScore.text = "PERFECT!!"
		$FinalScore.modulate = Color.GOLD
	elif(avg_score >= 7.0/8.0):
		$FinalScore.text = "Great!"
		$FinalScore.modulate = Color.SILVER
	elif(avg_score >= 3.0/4.0):
		$FinalScore.text = "Good"
		$FinalScore.modulate = Color.CADET_BLUE
	elif(avg_score >= 0.5):
		$FinalScore.text = "Nice"
		$FinalScore.modulate = Color.SANDY_BROWN
	else:
		$FinalScore.text = "Terrible"
		$FinalScore.modulate = Color.DARK_SEA_GREEN
	match gameStyle:
		STYLE.CLASSIC:
			$FinalScore.text += "\nScore: " + str(score) + " / " + str(ROUNDS * ROWS)
		STYLE.ENDLESS:
			if scoredSteps:
				$FinalScore.text += "\n Avg score: " + str(score / scoredSteps) + " / " + str(ROWS)
			else:
				$FinalScore.text += "\n Avg score: 0 / " + str(ROWS)
		STYLE.PERFECT:
			$FinalScore.text += "\n Perfect rounds: " + str(scoredSteps)
	$FinalScore.show()
	
	# Create a final score timer
	$BurnTimer.start(RESET_TIME)
	$BurnBar.max_value = RESET_TIME
	$BurnBar.value = 0

func _on_timer_timeout() -> void:
	# This timeout is for a game reset
	if !game_running:
		_ready()
		return
	
	if curOrb != null:
		orbDict[curOrb].highlight(false)
		curOrb = null
	
	# Move all other columns to new positions
	for col in range(COLS - 2, -1, -1):
		for row in range(ROWS):
			var index = Vector2i(col, row)
			var new_index = Vector2i(col + 1, row)
			var temp_x = orbDict[index].dest.x
			orbDict[index].dest.x = orbDict[new_index].dest.x
			orbDict[new_index].dest.x = temp_x
			orbDict[index].index = new_index
			#orbDict[index].swap(orbDict[new_index])
			# Swap
			var temp = orbDict[new_index]
			orbDict[new_index] = orbDict[index]
			orbDict[index] = temp
	
	var roundScore = 0
	var burnedCount = 0
	# Remove final column and calculate score
	for row in range(ROWS):
		var index = Vector2i(0, row)
		roundScore += orbDict[index].type - 1
		orbDict[index].dest.x = orbDict[index].position.x
		orbDict[index].SPEED = 2000
		orbDict[index].disconnect_all()
	
	# Move final column based on score
	for row in range(ROWS):
		var index = Vector2i(0, row)
		if(roundScore < 0):
			orbDict[index].dest.y = 10000
			if(orbDict[index].type == 2 and !orbDict[index].burned):
				burnedCount += 1
		else:
			if(orbDict[index].type == 2 and orbDict[index].burned):
				burnedCount += 1
			orbDict[index].dest.y = -10000
		orbDict[index].queue_redraw()
	
	if(roundScore > 0):
		# Game end for perfect mode
		if(roundScore - burnedCount != ROWS and gameStyle == STYLE.PERFECT):
			game_end()
			return
		# Check if perfect row to apply multiplier
		#if(roundScore == ROWS):
		#	perfectSteps += 1
		#else:
		#	perfectSteps = 0
		
		# Apply multiplier to score
		score += (roundScore - burnedCount) * (perfectSteps + 1)
		if roundScore == ROWS:
			$ScoreIndicator.text = "Perfect!"
			$ScoreIndicator.modulate = Color.AQUA
		elif(roundScore > ROWS * 3.0 / 4.0):
			$ScoreIndicator.text = "Nice"
			$ScoreIndicator.modulate = Color.WHITE
		elif(roundScore > ROWS / 2.0):
			$ScoreIndicator.text = "Okay"
			$ScoreIndicator.modulate = Color.GOLD
		else:
			$ScoreIndicator.text = "Meh."
			$ScoreIndicator.modulate = Color.WEB_GRAY
			
		$ScoreIndicator.reset()
		$ScoreIndicator.show()
		scoredSteps += 1
		$ScoreBar.value = scoredSteps
		var color = Color.BLACK
		color.r8 = 255 * (1 - score / (scoredSteps * float(ROWS)))
		color.g8 = 255 * (score / (scoredSteps * float(ROWS)))
		print(color, (1 - score / ROWS), (score / ROWS))
		$ScoreBar.modulate = color
	elif burnedCount > 0:
		$ScoreIndicator.text = "Waste!"
		$ScoreIndicator.modulate = Color.MEDIUM_PURPLE
		$ScoreIndicator.reset()
		$ScoreIndicator.show()
	steps += 1
	create_new_col(0, true, burnedCount)
	# Connect to newly created column
	for row in range(ROWS):
		connect_orbs(orbDict[Vector2i(1, row)])
	match gameStyle:
		STYLE.CLASSIC:
			$UI.get_node("Score").text = str(score)
		STYLE.PERFECT:
			$UI.get_node("Score").text = str(scoredSteps)
		STYLE.ENDLESS:
			if(scoredSteps > 0):
				$UI.get_node("Score").text = str(score / scoredSteps)
	
	$BurnTimer.start(BURN_TIME)
	$BurnBar.max_value = BURN_TIME
	$BurnBar.value = 0
	
	# Game end for classic mode
	if(scoredSteps == ROUNDS and gameStyle == STYLE.CLASSIC):
		game_end()
	
	pass # Replace with function body.

func _on_burn_bar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.is_action_pressed("click"):
			if $BurnBar.value > 1:
				_on_timer_timeout()
	pass # Replace with function body.

# Emulate timer timeout on user indication
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
			if $BurnBar.value > 1:
				_on_timer_timeout()

func _on_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.is_action_pressed("click"):
			if game_running:
				game_end()
			else:
				_ready()
	pass # Replace with function body.
