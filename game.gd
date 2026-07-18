extends Node2D

func spawn_mob():
	var new_mob = preload("res://mob.tscn").instantiate()
	%MobSpawnFollow.progress_ratio = randf()
	new_mob.global_position = %MobSpawnFollow.global_position
	add_child(new_mob)


func _on_mob_spawn_timer_timeout() -> void:
	spawn_mob()


func _on_player_health_depleted() -> void:
	%GameOver.show()
	get_tree().paused = true
