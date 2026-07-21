extends Control

func _on_play_button_pressed() -> void:
	%Timer.timeout.connect(func(): get_tree().change_scene_to_file("res://game.tscn"))
	%FadeScreen.fade_out(Color.WHITE, 1)
	%Timer.start(1)
