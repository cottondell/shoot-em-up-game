extends Area2D

var guns: Array[Gun]

func _process(delta: float) -> void:
	aim_guns()

func aim_guns():
	var enemies = get_enemies_by_range()
	
	for i in range(min(guns.size(), enemies.size())):
		guns[i].target = enemies[i]

class Node2DWithFloat:
	var node: Node2D
	var value: float
	
	func _init(node: Node2D, value: float) -> void:
		self.node = node
		self.value = value

func get_enemies_by_range() -> Array[Node2D]:
	# Improvement:
	# - Just use insertion sort with 1 loop which calculates distance then 
	#   inserts in into correct place in distances array, then inserts enemy 
	#   at same place in relevant array.
	
	var enemies_in_range: Array[Node2D] = get_overlapping_bodies()
	
	# Return empty array if no enemies in range
	if enemies_in_range.size() == 0:
		return enemies_in_range
	
	# Create array to hold enemies and their distances from the gun
	var enemies_with_distance:  Array[Node2DWithFloat]  = []
	enemies_with_distance.resize(enemies_in_range.size())
	
	# Calculate distances for all enemies
	for i in range(enemies_in_range.size()):
		var enemy = enemies_in_range[i]
		var distance = global_position.distance_to(enemy.global_position)
		enemies_with_distance[i] = Node2DWithFloat.new(enemy, distance)
	
	enemies_with_distance.sort_custom(func(a, b): a.value < b.value)
	
	for i in range(enemies_with_distance.size()):
		enemies_in_range[i] = enemies_with_distance[i].node
	
	return enemies_in_range
