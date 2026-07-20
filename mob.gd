class_name Mob
extends CharacterBody2D

signal health_depleted

@export var speed: float = 300.0
@onready var player = get_node("/root/Game/Player")

var health_pickup_spawn_chance: float = 0.1
var health: int = 3
var dead: bool = false

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
	# Ensure mob isn't killed twice before being deleted
	if dead:
		return
	dead = true
	
	# Delete self at end of frame
	queue_free()
	
	# Spawn smoke
	const SMOKE = preload("res://smoke_explosion/smoke_explosion.tscn")
	spawn_on_self(SMOKE, Vector2.ZERO)
	
	# Try spawn health pickup
	if randf() <= health_pickup_spawn_chance:
		const HEALTH_PICKUP = preload("res://health_pickup.tscn")
		spawn_on_self(HEALTH_PICKUP, Vector2(0, -32))
	
	health_depleted.emit()

func spawn_on_self(resource: Resource, offset: Vector2):
	var new: Node2D = resource.instantiate()
	new.global_position = global_position + offset
	call_deferred("add_to_parent", new)
	# ^ https://forum.godotengine.org/t/what-does-the-cant-change-this-state-while-flushing-queries-error-mean/25559/2
	# ^ "This error commonly occurs in the Godot Engine when you try to modify collision shapes or add/remove nodes directly while the physics engine is resolving collisions" - Google AI

func add_to_parent(node: Node2D):
	get_parent().add_child(node)
