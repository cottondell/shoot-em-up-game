class_name HUD
extends CanvasLayer

# TODO: As a general thing, make ability to show pop-up with text (like Minecraft titles)

@onready var wave_bar: WaveBar = %WaveBar

# Game over
func show_game_over():
	%GameOver.show()
	# Hide other UI elements?

func hide_game_over():
	%GameOver.hide()
