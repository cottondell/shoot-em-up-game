class_name HUD
extends CanvasLayer

# Game over
func show_game_over():
	%GameOver.show()

func hide_game_over():
	%GameOver.hide()

# Wave bar
func update_wave_bar(factor: float):
	%WaveBar.value = factor

func set_wave_number(wave: int):
	%WaveLabel.text = "Wave " + str(wave)
