extends Node2D

var wave = 0
var base_mob_count = 10
var extra_mobs_per_wave = 5
var mob_spawn_delay = 0.3

func _ready() -> void:
	next_wave()

func next_wave():
	wave += 1
	var mob_count = base_mob_count + wave * extra_mobs_per_wave
	%MobSpawner.start(mob_count, mob_spawn_delay)
	print("Started wave ", wave, " (", mob_count, " mobs)")

func wave_complete():
	print("Wave complete")

func end_game():
	%GameOver.show()
	get_tree().paused = true

func _on_player_health_depleted() -> void:
	end_game()

func _on_mob_spawner_mob_killed(progress: float) -> void:
	# TODO: Update wave progress bar
	
	if progress == 1:
		wave_complete()
