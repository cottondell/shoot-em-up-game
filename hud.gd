class_name HUD
extends CanvasLayer

# Wave bar
@onready var wave_bar: WaveBar = %WaveBar

# Game over
@onready var game_over_retry_button: Button = %RetryButton
@onready var game_over_menu_button: Button = %MenuButton

func show_game_over():
	%GameOver.show()
	%GameOverAnimation.play("fade_in")

func hide_game_over():
	%GameOver.hide()
	%GameOverAnimation.play("fade_out")

# Title (unused)
func show_title(text: String, time: float):
	%Title.text = text
	%Title.show()
	%TitleTimer.timeout.connect(%Title.hide)
	%TitleTimer.start(time)
