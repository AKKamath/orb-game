extends Label

var SPEED = 120
var startPos
var curColor


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startPos = position
	pass # Replace with function body.

func reset():
	position = startPos
	modulate.a8 = 255
	$IndicatorTimer.start(0.75)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_visible():
		position += position.direction_to(Vector2(position.x, 0)) * SPEED * delta
		modulate.a8 -= delta * SPEED
	pass

func _on_indicator_timer_timeout() -> void:
	hide()
	pass # Replace with function body.
