extends CanvasLayer

signal fade_complete

@export_enum("None", "Fade In", "Fade Out") var autostart: int
@export var autostart_colour: Color = Color.BLACK
@export var autostart_duration: int = 1

func _ready() -> void:
	if autostart == 1:
		fade_in(autostart_colour, autostart_duration)
	elif autostart == 2:
		fade_out(autostart_colour, autostart_duration)

func fade_in(colour: Color, duration: float):
	%ColorRect.color = colour
	%ColorRect.modulate = Color(1, 1, 1, 1)
	%AnimationPlayer.speed_scale = 1 / duration
	%AnimationPlayer.play("fade_in")
	print("Fade in")

func fade_out(colour: Color, duration: float):
	%ColorRect.color = colour
	%AnimationPlayer.speed_scale = 1 / duration
	%AnimationPlayer.play("fade_out")
	print("Fade out")

func _on_animation_finished(anim_name: StringName) -> void:
	fade_complete.emit()
