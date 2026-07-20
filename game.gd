extends Node2D

var wave := 0
var base_mob_count := 10
var extra_mobs_per_wave := 5
var mob_spawn_delay := 0.3
var wave_delay := 5.0
var is_in_wave := false

func _ready() -> void:
	# Trigger next_wave() when WaveTimer times out
	%WaveTimer.timeout.connect(next_wave)
	
	# Start wave timer for initial wave start
	%WaveTimer.start(wave_delay)

## Start the next wave.
func next_wave():
	if is_in_wave:
		return
	
	wave += 1
	var mob_count = base_mob_count + wave * extra_mobs_per_wave
	%MobSpawner.start(mob_count, mob_spawn_delay)
	
	print("Started wave ", wave, " (", mob_count, " mobs)")
	%HUD.wave_bar.start_wave(wave)

## End the game when the player's health is depleted.
func _on_player_health_depleted() -> void:
	%HUD.show_game_over()
	get_tree().paused = true

## Detect wave progression when mobs are killed.
func _on_mob_spawner_mob_killed(progress: float) -> void:
	%HUD.wave_bar.update(1.0 - progress)
	
	# Wave complete
	if progress >= 1.0:
		print("Wave complete, waiting ", wave_delay, "s until next wave")
		%HUD.wave_bar.start_intermission(wave_delay)
		%WaveTimer.start(wave_delay)
