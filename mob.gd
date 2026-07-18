class_name Mob
extends CharacterBody2D

@export var speed: float = 300.0
@onready var player = get_node("/root/Game/Player")

var health: int = 3

func _ready() -> void:
	%Slime.play_walk()

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()

func take_damage():
	health -= 1
	%Slime.play_hurt()
	
	if health <= 0:
		queue_free()
		
		const SMOKE = preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke: Node2D = SMOKE.instantiate()
		smoke.global_position = global_position
		get_parent().add_child(smoke)
