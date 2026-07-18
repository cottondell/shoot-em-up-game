extends Area2D

const SPEED: float = 1000.0
const RANGE: float = 1200.0

var distance_travelled: float = 0.0

func _physics_process(delta: float) -> void:
	# Move bullet
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	
	# Destroy bullet if travelled max range
	distance_travelled += SPEED * delta
	if distance_travelled > RANGE:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	# Destroy bullet
	queue_free()
	
	if body.has_method("take_damage"):
		body.take_damage()
