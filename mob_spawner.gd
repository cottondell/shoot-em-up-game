class_name MobSpawner
extends Node2D

signal mob_spawned(progress: float)
signal mob_killed(progress: float)

const _MOB_SCENE = preload("res://mob.tscn")
const MODE_DISABLED = 0
const MODE_ENABLED = 1

@export var spawn_path_follow: PathFollow2D

var _mode := MODE_DISABLED
var _target_count := 0
var _spawned_count := 0
var _died_count := 0

func start(count: int, delay: float) -> bool:
	if _mode != MODE_DISABLED:
		printerr("Mob spawner is already started - use stop() before starting again")
		return false
	
	if delay <= 0:
		printerr("Delay must be > 0")
		return false
	
	_target_count = count
	_spawned_count = 0
	_died_count = 0
	_mode = MODE_ENABLED
	%Timer.start(delay)
	
	return true

func stop():
	_mode = MODE_DISABLED
	%Timer.stop()

func is_started() -> bool:
	return _mode != MODE_DISABLED

func spawn_mob() -> Mob:
	if !spawn_path_follow:
		printerr("No spawn path is set - stopping timer")
		stop()
		return
	
	var new_mob: Mob = _MOB_SCENE.instantiate()
	new_mob.global_position = rand_position()
	new_mob.health_depleted.connect(_on_mob_killed)
	add_child(new_mob)
	
	return new_mob

func rand_position() -> Vector2:
	if !spawn_path_follow:
		return Vector2.ZERO
	
	spawn_path_follow.progress_ratio = randf()
	return spawn_path_follow.global_position

func _on_timer_timeout() -> void:
	if _mode == MODE_DISABLED:
		return
	elif _mode == MODE_ENABLED:
		spawn_mob()
		
		_spawned_count += 1
		if _spawned_count == _target_count:
			stop()
		
		var progress = clamp(_spawned_count / _target_count, 0.0, 1.0)
		mob_spawned.emit(progress)

func _on_mob_killed() -> void:
	_died_count += 1
	print("Mob died (", _died_count, ")")
	
	var progress = clamp(_died_count / _target_count, 0.0, 1.0)
	mob_killed.emit(progress)
