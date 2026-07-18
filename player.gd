extends CharacterBody2D

signal health_depleted

const SPEED: float = 600.0
const DAMAGE_RATE: float = 5.0

var health: float = 100.0

func _ready() -> void:
	%HealthBar.value = health

func _physics_process(delta: float) -> void:
	# Get move input
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Move player depending on input
	velocity = direction * SPEED
	move_and_slide()
	
	# Play correct animation
	if velocity.length() > 0.0:
		%HappyBoo.play_walk_animation()
	else:
		%HappyBoo.play_idle_animation()
	
	# Deal damage to player
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	
	if overlapping_mobs.size() > 0:
		health -= DAMAGE_RATE * overlapping_mobs.size() * delta
		%HealthBar.value = health
		
		if health <= 0:
			health = 0
			health_depleted.emit()
