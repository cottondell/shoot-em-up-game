extends Area2D

var health_value: float = 20.0
var despawn_after: float = 15.0

func _ready() -> void:
	%DespawnTimer.start(despawn_after)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var player: Player = body
		player.add_health(health_value)
		queue_free()

func _on_despawn_timer_timeout() -> void:
	queue_free()
