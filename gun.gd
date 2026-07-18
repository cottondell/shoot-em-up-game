extends Area2D

var target: Mob
@onready var normal_gun_visuals_scale_y = %Pistol.scale.y

func _physics_process(delta: float) -> void:
	if aim_at_target():
		fix_visuals_orientation()

func get_closest_enemy() -> Node2D:
	var enemies_in_range: Array[Node2D] = get_overlapping_bodies()
	
	# Return if no enemies in range
	if enemies_in_range.size() == 0:
		return
	
	# Set closest enemy to first one
	var closest_enemy: Node2D = enemies_in_range.pop_front()
	var closest_distance: float = global_position.distance_to(closest_enemy.global_position)
	
	# Loop through all other enemies
	for enemy in enemies_in_range:
		var enemy_distance = global_position.distance_to(enemy.global_position)
		
		# Check if enemy is closer than closest so far
		if enemy_distance < closest_distance:
			closest_enemy = enemy
			closest_distance = enemy_distance
	
	return closest_enemy

func aim_at_target() -> bool:
	# No target to aim at
	if !target:
		return false
	
	# Calculate naive new rotation to point at target
	var target_pos = target.global_position
	var angle_to_rotate = get_angle_to(target_pos)
	var new_rotation = rotation + angle_to_rotate
	
	# Ensure new rotation is between -PI and PI
	if new_rotation < -PI:
		new_rotation += 2 * PI
	elif new_rotation > PI:
		new_rotation -= 2 * PI
	
	# Set rotation
	rotation = new_rotation
	
	return true

func fix_visuals_orientation():
	if abs(rotation) > PI / 2:
		%Pistol.scale.y = -normal_gun_visuals_scale_y
	else:
		%Pistol.scale.y = normal_gun_visuals_scale_y

func shoot():
	const BULLET = preload("res://bullet.tscn")
	
	# Instantiate new bullet at shoot point with rotation of gun
	var new_bullet: Area2D = BULLET.instantiate()
	new_bullet.global_position = %ShootPoint.global_position
	new_bullet.rotation = rotation
	%ShootPoint.add_child(new_bullet)

func _on_shoot_timer_timeout() -> void:
	# Shoot if there is a target
	if target:
		shoot()

func _on_target_switch_timer_timeout() -> void:
	# Switch target by timer instead of each frame
	target = get_closest_enemy()
