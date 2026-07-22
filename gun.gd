class_name Gun
extends Node2D

# Constants
const BULLET = preload("res://bullet.tscn")
const MUZZLE_FLASH = preload("res://pistol/muzzle_flash/muzzle_flash.tscn")

# Public variables
var target: Node2D

# Private variables
var _autofire_enabled: bool = true
var _autofire_delay: float = 0.3
var _is_facing_right: bool = true
@onready var _facing_right_visual_scale_y = %Pistol.scale.y

# Engine events
func _ready() -> void:
	if _autofire_enabled:
		%AutofireTimer.start(_autofire_delay)

func _physics_process(_delta: float) -> void:
	# Try aim at target
	if _aim_at_target():
		# Flip orientation of gun visual if needed
		_fix_visual_orientation()

# Functions
## Fire a bullet from the shoot point of the gun.
func shoot():
	# Instantiate new bullet at shoot point with rotation of gun
	var new_bullet: Area2D = BULLET.instantiate()
	new_bullet.global_position = %ShootPoint.global_position
	new_bullet.global_rotation = global_rotation
	new_bullet.z_index = z_index - 1
	%ShootPoint.add_child(new_bullet)
	
	# Instantiate new muzzle flash at shoot point with rotation of gun
	var new_flash: Node2D = MUZZLE_FLASH.instantiate()
	%FlashPoint.add_child(new_flash)

# Autofire functions
func enable_autofire():
	if _autofire_enabled:
		return
	
	_autofire_enabled = true
	
	if is_node_ready():
		%AutofireTimer.start(_autofire_delay)

func disable_autofire():
	if !_autofire_enabled:
		return
	
	_autofire_enabled = false
	
	if is_node_ready():
		%AutofireTimer.stop()

func set_autofire_delay(delay: float):
	_autofire_delay = delay
	
	if _autofire_enabled && is_node_ready():
		%AutofireTimer.wait_time = delay

## Shoot gun when autofire timer times out
func _on_autofire_timer_timeout() -> void:
	# Shoot gun if autofire is enabled
	if _autofire_enabled:
		shoot()
	
	# Safety catch incase timer is enabled when it should be disabled
	else:
		%AutofireTimer.stop()

# Auto aim functions
## Rotate gun to point at target, if one is set.
func _aim_at_target() -> bool:
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

## Change y scale to flip gun depending on which direction it's facing.
func _fix_visual_orientation():
	var new_is_facing_right = abs(rotation) < PI / 2
	
	# Not changed -> don't do anything
	if _is_facing_right == new_is_facing_right:
		return
	
	# Changed -> update facing
	_is_facing_right = new_is_facing_right
	
	# Facing right = set normal scale
	if _is_facing_right:
		%Pistol.scale.y = _facing_right_visual_scale_y
	
	# Facing left = set negative of normal scale
	else:
		%Pistol.scale.y = -_facing_right_visual_scale_y
