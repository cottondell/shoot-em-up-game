extends CharacterBody2D

# Declare signals
signal health_depleted

# Stats
var speed: float = 600.0
var damage_rate: float = 5.0
var health: float = 100.0

# State
var was_walking: bool = false

# Base game-state functions
func _ready() -> void:
	%HealthBar.value = health
	
	for i in range(1):
		const GUN = preload("res://gun.tscn")
		
		var new_gun: Gun = GUN.instantiate()
		new_gun.enable_autofire()
		
		%GunHandler.add_child(new_gun)
		%GunHandler.guns.append(new_gun)

func _physics_process(delta: float) -> void:
	update_player_movement()
	calculate_damage_self(delta)

# Take user input to move player
func update_player_movement():
	# Get move input
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_walking := direction.length_squared() > 0.0
	
	# Move player if directional input is given
	if is_walking:
		velocity = direction * speed
		move_and_slide()
		
		# Check if player started walking this frame
		if !was_walking:
			was_walking = true
			%HappyBoo.play_walk_animation()
	
	# Check if player stopped walking this frame
	elif was_walking:
		was_walking = false
		%HappyBoo.play_idle_animation()

# Calculate damage that should be applied to player and deal it
func calculate_damage_self(delta: float):
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		health -= damage_rate * overlapping_mobs.size() * delta
		%HealthBar.value = health
		
		if health <= 0:
			health = 0
			health_depleted.emit()
