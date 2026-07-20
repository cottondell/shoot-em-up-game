class_name WaveBar
extends ProgressBar

var lerp_active: bool = false
var lerp_speed: float = 1.0
var lerp_value: float = 0.0

func _process(delta: float) -> void:
	if lerp_active:
		lerp_value += lerp_speed * delta
		
		if lerp_value >= 1:
			lerp_value = 1
			lerp_active = false
		
		value = lerp_value

func start_wave(wave_number: int):
	# TODO: Set fill colour
	lerp_active = false
	value = 1
	%WaveLabel.text = "Wave " + str(wave_number)
	%WaveLabel.show()

func start_intermission(time: float):
	# TODO: Set fill colour
	value = 0
	lerp_value = 0
	lerp_speed = 1 / time
	lerp_active = true
	%WaveLabel.hide()

func update(factor: float):
	if !lerp_active:
		value = factor
