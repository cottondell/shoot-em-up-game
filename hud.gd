class_name HUD
extends CanvasLayer

# TODO: As a general thing, make ability to show pop-up with text (like Minecraft titles)

# Wave bar
@onready var wave_bar: WaveBar = %WaveBar

# Game over
func show_game_over():
	%GameOver.show()
	# Hide other UI elements?

func hide_game_over():
	%GameOver.hide()

# Title
func show_title(text: String, time: float):
	%Title.text = text
	%Title.show()
	%TitleTimer.timeout.connect(%Title.hide)
	%TitleTimer.start(time)
