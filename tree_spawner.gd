extends Node2D

# Idea:
# - Split world into grid
# - Create a rectangle bigger than the screen to specify how far out trees spawn
# - Use rectangle's bounds to see when player passes over grid positions just outside viewable area
# - Use noise map to decide if tree should be spawned on grid positions
# - Spawn trees if no recycled ones can be used
# - When trees go out of view, recycle them (make invisible & add to unused trees array)

const DEBUG_MODE: bool = true

const TREE: Resource = preload("res://tree.tscn")
const TREE_SPACING: Vector2 = Vector2(124, 100)

const SCREEN_SIZE: Vector2 = Vector2(1920, 1080)
const SPAWN_BOX_OFFSET: Vector2 = Vector2(100, 200)

@export var player: Node2D
@export var noise_map: FastNoiseLite

var spawned_trees: Dictionary[Vector2, Node2D] = {}
var unused_trees: Array[Node2D] = []
var last_grid_negative_bounds: Vector2i
var last_grid_positive_bounds: Vector2i

func _ready() -> void:
	if !player:
		printerr("Player not set!")
	
	if !noise_map:
		noise_map = FastNoiseLite.new()
		noise_map.noise_type = FastNoiseLite.TYPE_VALUE
	
	noise_map.seed = floor(Time.get_unix_time_from_system())
	
	if DEBUG_MODE:
		%DebugUI.show()
	else:
		%DebugUI.hide()

func _process(_delta: float) -> void:
	if !player:
		return
	
	const SPAWN_BOX_BOUNDS = (SCREEN_SIZE + SPAWN_BOX_OFFSET) / 2
	
	# Calculate bounds of spawn box
	var negative_bounds = player.global_position - SPAWN_BOX_BOUNDS
	var positive_bounds = player.global_position + SPAWN_BOX_BOUNDS
	
	# Calculate bounds as grid positions
	var grid_negative_bounds = (negative_bounds / TREE_SPACING).floor()
	var grid_positive_bounds = (positive_bounds / TREE_SPACING).ceil()
	
	# Grid bounds haven't changed so do nothing
	if !update_last_bounds(grid_negative_bounds, grid_positive_bounds):
		return
	
	# Remove trees leaving view
	check_for_old_trees(grid_negative_bounds, grid_positive_bounds)
	
	# Create trees coming into view
	check_for_new_trees(grid_negative_bounds, grid_positive_bounds)

func update_last_bounds(grid_negative_bounds: Vector2i, grid_positive_bounds: Vector2i) -> bool:
	# Check if either positive or negative grid bounds have changed
	var negative_changed = grid_negative_bounds != last_grid_negative_bounds
	var positive_changed = grid_positive_bounds != last_grid_positive_bounds
	
	# If not, don't try spawn any trees
	if !(negative_changed || positive_changed):
		return false
	
	# Update last bounds
	last_grid_negative_bounds = grid_negative_bounds
	last_grid_positive_bounds = grid_positive_bounds
	
	return true

func check_for_old_trees(grid_negative_bounds: Vector2i, grid_positive_bounds: Vector2i):
	# 
	const OFFSET = Vector2i(1, 1)
	grid_negative_bounds -= OFFSET
	grid_positive_bounds += OFFSET
	
	for grid_x in range(grid_negative_bounds.x, grid_positive_bounds.x + 1):
		try_remove_tree(grid_x, grid_negative_bounds.y - 1)
		try_remove_tree(grid_x, grid_positive_bounds.y + 1)
	
	for grid_y in range(grid_negative_bounds.y - 1, grid_positive_bounds.y):
		try_remove_tree(grid_negative_bounds.x - 1, grid_y)
		try_remove_tree(grid_positive_bounds.x + 1, grid_y)

func check_for_new_trees(grid_negative_bounds: Vector2i, grid_positive_bounds: Vector2i):
	# Loop over top & bottom edges of spawn box
	for grid_x in range(grid_negative_bounds.x, grid_positive_bounds.x + 1):
		try_spawn_tree(grid_x, grid_negative_bounds.y)
		try_spawn_tree(grid_x, grid_positive_bounds.y)
	
	# Loop over left & right edges of spawn box
	for grid_y in range(grid_negative_bounds.y + 1, grid_positive_bounds.y):
		try_spawn_tree(grid_negative_bounds.x, grid_y)
		try_spawn_tree(grid_positive_bounds.x, grid_y)

func try_remove_tree(grid_x: int, grid_y: int):
	var grid_position = Vector2(grid_x, grid_y)
	
	if !spawned_trees.has(grid_position):
		return
	
	var tree = spawned_trees[grid_position]
	tree.hide()
	
	unused_trees.append(tree)
	spawned_trees.erase(grid_position)
	update_debug_ui()

func try_spawn_tree(grid_x: int, grid_y: int) -> bool:
	var grid_position = Vector2(grid_x, grid_y)
	var tree_position = grid_position * TREE_SPACING
	
	if spawned_trees.has(grid_position):
		return false
	
	var value = noise_map.get_noise_2dv(grid_position)
	var spawn_tree = abs(value) > 0.6 #|| (value > 0.05 && value < 0.1)
	
	if !spawn_tree:
		return false
	
	# Recycle new tree or instantiate new one
	var new_tree: Node2D
	
	if unused_trees.size() != 0:
		new_tree = unused_trees.pop_front()
		new_tree.global_position = tree_position
		new_tree.show()
	else:
		new_tree = TREE.instantiate()
		new_tree.global_position = tree_position
		add_child(new_tree)
	
	spawned_trees[grid_position] = new_tree
	update_debug_ui()
	return true

func update_debug_ui():
	if !DEBUG_MODE:
		return
	%DebugLabel.text = "Spawned trees: " + str(spawned_trees.size()) + "\nUnused trees: " + str(unused_trees.size())
