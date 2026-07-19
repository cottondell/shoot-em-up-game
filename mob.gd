class_name Mob
extends CharacterBody2D

@export var speed: float = 300.0
@onready var player = get_node("/root/Game/Player")

var health: int = 3
var health_pickup_spawn_chance: float = 0.1

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
		kill()

func kill():
	# Delete self at end of frame
	queue_free()
	
	# Spawn smoke
	const SMOKE = preload("res://smoke_explosion/smoke_explosion.tscn")
	spawn_on_self(SMOKE, Vector2.ZERO)
	
	# Try spawn health pickup
	if randf() <= health_pickup_spawn_chance:
		const HEALTH_PICKUP = preload("res://health_pickup.tscn")
		spawn_on_self(HEALTH_PICKUP, Vector2(0, -32))

func spawn_on_self(resource: Resource, offset: Vector2):
	print("Spawning " + resource.resource_path)
	
	var new: Node2D = resource.instantiate()
	new.global_position = global_position + offset
	call_deferred("add_to_parent", new)

func add_to_parent(node: Node2D):
	get_parent().add_child(node)
