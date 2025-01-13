extends Area2D
# Emits current orb index, whether it was (un)selected, and whether dragged
signal clicked(index, selected, dragged)
@export var radius : int
@export var type : int
@export var index : Vector2i
@export var SPEED : int = 200
@export var burned : bool = false

const BASE_SPEED = 300
const SWAP_SPEED = 1000

var TYPE_COLOR = {
	0 : Color.CADET_BLUE,
	1 : Color.CHOCOLATE,
	2 : Color.DARK_ORCHID,
}

var dest
var highlighted = false
var connectedOrbs = {}

var connectedLines = {}

func connect_orb(orb):
	#print("Connected ", index, " to ", orb.index)
	connectedOrbs[orb] = orb
	if(orb.type != type and dest.x > orb.dest.x):
		if(can_swap(orb)):
			var line = Line2D.new()
			line.hide()
			line.add_point(Vector2.ZERO)
			line.add_point(orb.dest - dest)
			line.set_default_color(Color.GREEN_YELLOW)
			line.set_width(10)
			line.z_index = -2
			line.set_light_mask(9)
			add_child(line)
			connectedLines[orb] = line
	queue_redraw()
	
func disconnect_orb(orb) -> void:
	print(orb.index)
	if orb in connectedLines:
		connectedLines[orb].queue_free()
		connectedLines.erase(orb)
	if orb in connectedOrbs:
		#print(index, "Disconnected", orb.index)
		connectedOrbs.erase(orb)
		queue_redraw()
	pass # Replace with function body.

func disconnect_all():
	for orb in connectedLines:
		connectedLines[orb].queue_free()
	connectedLines.clear()
	connectedOrbs.clear()
	queue_redraw()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	queue_redraw()
	if dest == null:
		dest = position
	highlighted = false
	SPEED = BASE_SPEED#get_viewport().size.x * 0.2
	
	# Init sizes
	$CollisionShape2D.shape.radius = radius
	$MeshInstance2D.scale.x = radius * 2 * 0.8
	$MeshInstance2D.scale.y = radius * 2 * 0.8
	
func redraw():
	$CollisionShape2D.shape.radius = radius
	$MeshInstance2D.scale.x = radius * 2 * 0.8
	$MeshInstance2D.scale.y = radius * 2 * 0.8
	for orb in connectedLines:
		var line : Line2D = connectedLines[orb]
		line.clear_points()
		line.add_point(Vector2.ZERO)
		line.add_point(orb.dest - dest)
		line.set_width(radius / 5)
	_draw()
	
func can_swap(orb):
	return ((orb.type - type == 1 || orb.type - type == -2) and orb.dest.y < dest.y) or \
		((orb.type - type == -1 || orb.type - type == 2) and orb.dest.y > dest.y)
	

func _draw() -> void:
	var subValX = Vector2(radius * 0.7, 0)
	var subValY = Vector2(0, radius * 0.7)
	if(position == dest):
		for orb in connectedOrbs:
			if(orb.type != type and dest.x > orb.dest.x):
				if(can_swap(orb)):
					connectedLines[orb].show()
					pass
					#draw_line(Vector2.ZERO, orb.dest - dest, Color.BISQUE, 5)
				#elif(can_swap(orb) and ):
				#	draw_line(Vector2.ZERO, orb.dest - dest, Color.BISQUE, 5)
	
	if highlighted:
		draw_circle(Vector2.ZERO, radius * 0.8, TYPE_COLOR[type].darkened(-0.7), false, radius * 0.1)
	else:
		draw_circle(Vector2.ZERO, radius * 0.8, Color.BLACK, false, 3)

	if burned:
		$MeshInstance2D.texture.gradient.set_color(0, TYPE_COLOR[type].darkened(0.6))
		#draw_circle(Vector2.ZERO, radius * 0.8, TYPE_COLOR[type].darkened(0.6))
	else:
		$MeshInstance2D.texture.gradient.set_color(0, TYPE_COLOR[type])
		#draw_circle(Vector2.ZERO, radius * 0.8, TYPE_COLOR[type])

	# Draw +
	if(type == 2 and !burned):
		draw_line(Vector2.ZERO - subValX, Vector2.ZERO + subValX, Color.ALICE_BLUE, 5)
		draw_line(Vector2.ZERO - subValY, Vector2.ZERO + subValY, Color.ALICE_BLUE, 5)
	elif type == 1:
		draw_circle(Vector2.ZERO, radius * 0.4, Color.ALICE_BLUE, false, 5)
	elif type == 0 or burned:
		draw_line(Vector2.ZERO - subValX, Vector2.ZERO + subValX, Color.ALICE_BLUE, 5)

func swap(node):
	#Swap node positions
	var temp_dest = dest
	dest = node.dest
	node.dest = temp_dest
	
	# Swap node index labels
	var temp_ind = index
	index = node.index
	node.index = temp_ind
	
	highlighted = false
	disconnect_all()
	queue_redraw()
	
	node.highlighted = false
	node.disconnect_all()
	node.queue_redraw()
	
	node.SPEED = SWAP_SPEED
	SPEED = SWAP_SPEED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if position != dest:
		if(abs(position.distance_to(dest)) < abs(SPEED * delta)):
			position = dest
			queue_redraw()
			SPEED = BASE_SPEED
		else:
			position += position.direction_to(dest) * SPEED * delta
	pass
	
func highlight(on : bool):
	highlighted = on
	queue_redraw()
	
func orb_clicked(dragged : bool = false):
	if !highlighted:
		print("Emitting")
		clicked.emit(index, true, dragged)
	elif !dragged:
		clicked.emit(index, false, dragged)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.is_action_pressed("click"):
			print(event)
			orb_clicked(false)
	pass # Replace with function body.


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	if dest.y == 10000 or dest.y == -10000:
		queue_free()
	pass # Replace with function body.


func _on_mouse_entered() -> void:
	if Input.is_action_pressed("click"):
		orb_clicked(true)
	pass # Replace with function body.

func _on_mouse_exited() -> void:
	pass # Replace with function body.
