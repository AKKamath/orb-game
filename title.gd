extends Control
@export var orbObj : PackedScene

var difficulty : int = Util.DIFF.NORMAL
var style : int = Util.STYLE.CLASSIC
var done_start = false

var ROWS = 4
var COLS = 4

var orbDict = {}
func calc_pos(box: Vector2, radius: int, x : int, y : int):
	return Vector2(x * box.x / COLS + radius, 
				y * box.y / ROWS + radius + (x % 2) * radius)

# Connect the orb to its neighbors
func connect_orbs(newOrb):
	var i = newOrb.index.x
	var j = newOrb.index.y
	if(i > 0):
		newOrb.connect_orb(orbDict[Vector2i(i - 1, j)])
		if((i % 2) == 1):
			if(j < ROWS - 1):
				newOrb.connect_orb(orbDict[Vector2i(i - 1, j + 1)])
		elif (j > 0):
			newOrb.connect_orb(orbDict[Vector2i(i - 1, j - 1)])

var TCOLOR = {
	0 : Color.CADET_BLUE,
	1 : Color.CHOCOLATE,
	2 : Color.DARK_ORCHID,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Setup initial options
	$StyleUI/StyleOpts/ClassicButton.button_pressed = true
	difficulty = Util.DIFF.NORMAL
	$DifficultyUI/DifficultyOpts/NormalButton.button_pressed = true
	style = Util.STYLE.CLASSIC
	
	# Add color to our buttons
	$StyleUI/StyleOpts/EndlessButton.modulate       = TCOLOR[0]
	$StyleUI/StyleOpts/ClassicButton.modulate       = TCOLOR[1]
	$StyleUI/StyleOpts/PerfectionistButton.modulate = TCOLOR[2]
	
	
	$InsBox.hide()
	$InsPanel.hide()
	var radius = 10
	var box = $InsPanel.size
	# Setup instruction orbs
	for i in range(COLS):
		for j in range(ROWS):
			var newOrb = orbObj.instantiate()
			newOrb.type = randi() % 3
			newOrb.index = Vector2i(i, j)
			#newOrb.clicked.connect(_on_orb_clicked.bind())
			# Add orb to our database
			orbDict[newOrb.index] = newOrb
			print("Created ", newOrb.index)
			$InsPanel.add_child(newOrb)
	_on_resized()

func _on_resized() -> void:
	# Redraw UI elements
	var vp = get_viewport().size
	
	# Instruction box takes up 25% of horizontal space, 
	# Orb diagram takes up other space
	$InsBox.size.x = vp.x * 0.3
	$InsBox.size.y = vp.y * 0.4
	$InsBox/Instructions.custom_minimum_size.x = $InsBox.size.x
	
	$InsBox.position.x = vp.x * 0.1 + \
		(vp.x * 0.4 - $InsBox.size.x) / 2
	$InsBox.position.y = (vp.y - $InsBox.size.y) / 2
	
	$InsPanel.size.x = vp.x * 0.3
	$InsPanel.size.y = vp.y * 0.4
	
	$InsPanel.position.x = vp.x * 0.5 + (vp.x * 0.4 - $InsPanel.size.x) / 2
	$InsPanel.position.y = (vp.y - $InsPanel.size.y) / 2
	
	var box = $InsPanel.size
	# Redraw orbs
	var radius = min(box.x / COLS, box.y / ROWS) / 2
	for i in range(COLS):
		for j in range(ROWS):
			if(Vector2i(i, j) in orbDict):
				var curOrb = orbDict[Vector2i(i, j)]
				# Initialize orb data
				var pos = calc_pos(box, radius, i, j)
				curOrb.dest = pos
				curOrb.position = pos
				curOrb.radius = radius
				curOrb.disconnect_all()
				# Connect to neighboring orbs
				connect_orbs(curOrb)
				curOrb.redraw()
	var y_off = 0
	# TITLE: Center-align, 20% vertical space
	$Title/orb.radius = $Title.size.y / 2
	$Title/orb.redraw()
	# To center align, get midpoint by taking screen X - (sizeof title)
	$Title.position.x = (vp.x - ($Title.size.x * $Title.scale.x + 2 * $Title/orb.radius)) / 2 \
		+ $Title/orb.radius * 2 + 60
	$Title.position.y = (vp.y * 0.2 - $Title.size.y) / 2
	y_off += vp.y * 0.2
	
	# Util.STYLE: 30% vertical space
	$StyleUI.position.x = (vp.x - $StyleUI.size.x) / 2
	$StyleUI.position.y = y_off + (vp.y * 0.3) / 2
	y_off += 0.3 * vp.y
	
	# Util.DIFFICULTY: 10% vertical space, keep it close to difficulty
	$DifficultyUI.position.x = (vp.x - $DifficultyUI.size.x) / 2
	$DifficultyUI.position.y = y_off + (vp.y * 0.1) / 2
	y_off += 0.1 * vp.y
	
	# START: 30% vertical space
	$StartContainer.position.x = (vp.x - $StartContainer.size.x) / 2
	$StartContainer.position.y = y_off + (vp.y * 0.3) / 2
	
	# 10% padding

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Some small animation for effect
	$Title/orb/MeshInstance2D/PointLight2D.rotation += delta
	$Title/orb/MeshInstance2D/PointLight2D2.rotation += delta
	pass


func _on_easy_button_toggled(toggled_on: bool) -> void:
	difficulty = Util.DIFF.EASY
	$Title/orb.type = 0
	$Title/orb.queue_redraw()
	$DifficultyUI/DifficultyDescription.text = "Orbs are removed every 15 seconds."
	pass # Replace with function body.


func _on_normal_button_toggled(toggled_on: bool) -> void:
	difficulty = Util.DIFF.NORMAL
	$Title/orb.type = 1
	$Title/orb.queue_redraw()
	$DifficultyUI/DifficultyDescription.text = "Orbs are removed every 10 seconds."
	pass # Replace with function body.


func _on_hard_button_toggled(toggled_on: bool) -> void:
	difficulty = Util.DIFF.HARD
	$Title/orb.type = 2
	$Title/orb.queue_redraw()
	$DifficultyUI/DifficultyDescription.text = "Orbs are removed every 5 seconds."
	pass # Replace with function body.


func _on_classic_toggled(toggled_on: bool) -> void:
	style = Util.STYLE.CLASSIC
	$Title/orb.type = 1
	$Title/orb.queue_redraw()
	$StyleUI/TypeDescription.text = "Classic gameplay. 10 scored rounds."
	pass # Replace with function body.


func _on_endless_toggled(toggled_on: bool) -> void:
	style = Util.STYLE.ENDLESS
	$Title/orb.type = 0
	$Title/orb.queue_redraw()
	$StyleUI/TypeDescription.text = "Endless rounds. Score is average per round."
	pass # Replace with function body.


func _on_perfectionist_toggled(toggled_on: bool) -> void:
	style = Util.STYLE.PERFECT
	$Title/orb.type = 2
	$Title/orb.queue_redraw()
	$StyleUI/TypeDescription.text = "Scored column must be all positive orbs. Score is rounds survived."
	pass # Replace with function body.


func _on_start_button_pressed() -> void:
	var root = get_parent().get_parent()
	# Remove the title screen
	var level = root.get_node("TitleScreen")
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


func _on_instruction_button_toggled(toggled_on: bool) -> void:
	$InsBox.visible = toggled_on
	$InsPanel.visible = toggled_on
	$StyleUI.visible = !toggled_on
	$DifficultyUI.visible = !toggled_on
	$StartContainer/StartButton.visible = !toggled_on
	pass # Replace with function body.
