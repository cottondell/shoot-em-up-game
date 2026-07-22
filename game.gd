extends Node2D

var wave := 0
var base_mob_count := 10
var extra_mobs_per_wave := 5
var mob_spawn_delay := 0.3
var wave_delay := 5.0
var is_in_wave := false

func _ready() -> void:
	%HUD.game_over_retry_button.pressed.connect(restart)
	%HUD.game_over_menu_button.pressed.connect(exit_to_main_menu)
	
	# Show wave bar for initial intermission
	%HUD.wave_bar.start_intermission(wave_delay)
	%HUD.wave_bar.set_text("Intermission")
	%HUD.wave_bar.show()
	
	# Set-up wave timer listener & start initial intermission
	%WaveTimer.timeout.connect(next_wave)
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

## Restart the game.
func restart():
	# Start screen fade
	%FadeScreen.fade_out(Color.WHITE, 1)
	
	# Switch scene in 1s with a SceneTreeTimer
	get_tree().create_timer(1.0).timeout.connect(func():
		get_tree().paused = false
		get_tree().reload_current_scene())

func exit_to_main_menu():
	# Start screen fade
	%FadeScreen.fade_out(Color.BLACK, 1)
	
	# Switch scene in 1s with a SceneTreeTimer
	get_tree().create_timer(1.0).timeout.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://main_menu.tscn"))
	

## End the game when the player's health is depleted.
func _on_player_health_depleted() -> void:
	%WaveTimer.stop() # Safety in-case player dies in intermission (shouldn't happend currently)
	%HUD.show_game_over()
	get_tree().paused = true

## Detect wave progression when mobs are killed.
func _on_mob_spawner_mob_killed(progress: float) -> void:
	# Update wave bar
	%HUD.wave_bar.update(1.0 - progress)
	
	# Wave complete, start intermission
	if progress >= 1.0:
		print("Wave complete, intermission for ", wave_delay, "s")
		%HUD.wave_bar.start_intermission(wave_delay)
		%HUD.wave_bar.set_text("WAVE COMPLETE!")
		%WaveTimer.start(wave_delay)
