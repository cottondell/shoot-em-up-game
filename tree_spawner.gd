extends Node2D

# Idea:
# - Split world into grid
# - Create a rectangle bigger than the screen to specify how far out trees spawn
# - Use rectangle's bounds to see when player passes over grid positions just outside viewable area
# - Use noise map to decide if tree should be spawned on grid positions
# - Spawn trees if no recycled ones can be used
# - When trees go out of view, recycle them (make invisible & add to unused trees array)

# Improvements:
# - Make an iterator for iterating along the outside of a box:
#     https://docs.godotengine.org/en/latest/tutorials/scripting/gdscript/gdscript_advanced.html#custom-iterators

const DEBUG_MODE: bool = true

const TREE: Resource = preload("res://tree.tscn")
const TREE_SPACING: Vector2 = Vector2(124, 100)

const SCREEN_SIZE: Vector2 = Vector2(1920, 1080)
const SPAWN_BOX_OFFSET: Vector2 = Vector2(100, 200)

@export var player: Node2D
@export var noise_map: FastNoiseLite

var spawned_trees: Dictionary[Vector2, Node2D] = {}
var unused_trees: Array[Node2D] = []
var last_min_bounds_grid: Vector2i
var last_max_bounds_grid: Vector2i

func _ready() -> void:
	# Error if no player is set
	if !player:
		printerr("Player not set!")
		return
	
	# Create default noise map if one isn't provided
	if !noise_map:
		noise_map = FastNoiseLite.new()
		noise_map.noise_type = FastNoiseLite.TYPE_VALUE
	
	# Randomise noise map seed
	noise_map.seed = floor(Time.get_unix_time_from_system())
	
	# Set debug ui visibility depending on DEBUG_MODE
	if DEBUG_MODE:
		%DebugUI.show()
	else:
		%DebugUI.hide()

func _process(_delta: float) -> void:
	if !player:
		return
	
	const SPAWN_BOX_BOUNDS = (SCREEN_SIZE + SPAWN_BOX_OFFSET) / 2
	
	# Calculate bounds of spawn box
	var min_bounds = player.global_position - SPAWN_BOX_BOUNDS
	var max_bounds = player.global_position + SPAWN_BOX_BOUNDS
	
	# Calculate bounds as grid positions
	var min_bounds_grid = (min_bounds / TREE_SPACING).floor()
	var max_bounds_grid = (max_bounds / TREE_SPACING).ceil()
	
	# Remove / spawn trees if grid bounds have changed
	if update_last_bounds(min_bounds_grid, max_bounds_grid):
		remove_leaving_trees(min_bounds_grid, max_bounds_grid)
		spawn_entering_trees(min_bounds_grid, max_bounds_grid)

## Check if bounds have changed since last frame and update them.
func update_last_bounds(min_bounds_grid: Vector2i, max_bounds_grid: Vector2i) -> bool:
	# Check if either positive or negative grid bounds have changed
	var min_changed = min_bounds_grid != last_min_bounds_grid
	var max_changed = max_bounds_grid != last_max_bounds_grid
	
	# If not, don't try spawn any trees
	if !(min_changed || max_changed):
		return false
	
	# Update last bounds
	last_min_bounds_grid = min_bounds_grid
	last_max_bounds_grid = max_bounds_grid
	
	return true

## Remove all trees leaving the view.
func remove_leaving_trees(min_bounds_grid: Vector2i, max_bounds_grid: Vector2i):
	# Extend spawn box to get removal box
	const OFFSET = Vector2i(1, 1)
	min_bounds_grid -= OFFSET
	max_bounds_grid += OFFSET
	
	# Loop over top & bottom edges of removal box
	for grid_x in range(min_bounds_grid.x, max_bounds_grid.x + 1):
		try_remove_tree(grid_x, min_bounds_grid.y - 1)
		try_remove_tree(grid_x, max_bounds_grid.y + 1)
	
	# Loop over left & right edges of removal box
	for grid_y in range(min_bounds_grid.y - 1, max_bounds_grid.y):
		try_remove_tree(min_bounds_grid.x - 1, grid_y)
		try_remove_tree(max_bounds_grid.x + 1, grid_y)

## Spawn all trees entering the view.
func spawn_entering_trees(min_bounds_grid: Vector2i, max_bounds_grid: Vector2i):
	# Loop over top & bottom edges of spawn box
	for grid_x in range(min_bounds_grid.x, max_bounds_grid.x + 1):
		try_spawn_tree(grid_x, min_bounds_grid.y)
		try_spawn_tree(grid_x, max_bounds_grid.y)
	
	# Loop over left & right edges of spawn box
	for grid_y in range(min_bounds_grid.y + 1, max_bounds_grid.y):
		try_spawn_tree(min_bounds_grid.x, grid_y)
		try_spawn_tree(max_bounds_grid.x, grid_y)

## Remove a tree at the position if one exists.
func try_remove_tree(grid_x: int, grid_y: int):
	var grid_position = Vector2(grid_x, grid_y)
	
	if !spawned_trees.has(grid_position):
		return
	
	var tree = spawned_trees[grid_position]
	tree.hide()
	
	unused_trees.append(tree)
	spawned_trees.erase(grid_position)
	update_debug_ui()

## Spawn a tree at the position if there should be one there.
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
