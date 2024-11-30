extends Node2D

var overworld_tilemap : TileMapLayer
var mirror_tilemap : TileMapLayer
var generators : Array[Vector2i]
var sensors : Array[Vector2i] # Only in overworld dimension
var spikes : Array[Vector2i]
var overworld_cables : Dictionary
var mirror_cables : Dictionary
var checked_cables : Array
var pressure_plates : Dictionary
var all_boxes : Dictionary

var on_screen = false
var solved: bool = false

func _ready() -> void:
	overworld_tilemap = $Tilemaps/Overworld
	mirror_tilemap = $Tilemaps/MirrorWorld
	
	# Generators
	generators = overworld_tilemap.get_used_cells_by_id(0, Vector2(10, 0))
	
	# Cables
	overworld_cables = {}
	mirror_cables = {}
	
	for x in range(6, 8):
		for y in range(0, 6):
			for cell in overworld_tilemap.get_used_cells_by_id(0, Vector2(x, y)):
				overworld_cables[cell] = Vector2i(x, y)
			for cell in mirror_tilemap.get_used_cells_by_id(0, Vector2(x, y)):
				mirror_cables[cell] = Vector2i(x, y)
	
	# Sensors
	sensors = overworld_tilemap.get_used_cells_by_id(0, Vector2(10, 2))
	
	# Spikes
	spikes = overworld_tilemap.get_used_cells_by_id(0, Vector2(11, 3))
			
	# Boxes		
	for cell in overworld_tilemap.get_used_cells_by_id(0, Vector2(11, 0)):
		pressure_plates[cell] = "overworld"
	for cell in mirror_tilemap.get_used_cells_by_id(0, Vector2(11, 0)):
		pressure_plates[cell] = "mirror"
		
	var overworld_boxes = overworld_tilemap.get_used_cells_by_id(0, Vector2i(10, 4))
	for cell in overworld_boxes:
		var box = load("res://scenes/object/box.tscn").instantiate()
		overworld_tilemap.set_cell(cell, 0, Vector2i(2, 1))
		box.new_position = overworld_tilemap.map_to_local(cell)
		box.global_position = to_global(overworld_tilemap.map_to_local(cell))
		box.tilemap = overworld_tilemap
		add_child(box)
		all_boxes[box] = "overworld"
		
	var mirror_boxes = mirror_tilemap.get_used_cells_by_id(0, Vector2i(11, 4))
	for cell in mirror_boxes:
		var box = load("res://scenes/object/box.tscn").instantiate()
		mirror_tilemap.set_cell(cell, 0, Vector2i(2, 4))
		box.new_position = mirror_tilemap.map_to_local(cell)
		box.global_position = to_global(mirror_tilemap.map_to_local(cell))
		box.tilemap = mirror_tilemap
		box.mirrored = true
		add_child(box)
		all_boxes[box] = "mirror"
		
	var crossing_boxes = overworld_tilemap.get_used_cells_by_id(0, Vector2i(10, 5))
	for cell in crossing_boxes:
		var crossing_box = load("res://scenes/object/crossing_box.tscn").instantiate()
		overworld_tilemap.set_cell(cell, 0, Vector2i(2, 1))
		crossing_box.new_position = overworld_tilemap.map_to_local(cell)
		crossing_box.global_position = to_global(overworld_tilemap.map_to_local(cell))
		crossing_box.tilemap = overworld_tilemap
		crossing_box.mirrored = false
		add_child(crossing_box)
		all_boxes[crossing_box] = "crossing"
		
	# Fixed lantern
	var fixed_lanterns = overworld_tilemap.get_used_cells_by_id(0, Vector2i(10, 1))
	for cell in fixed_lanterns:
		var fixed_lantern = load("res://scenes/object/fixed_lantern.tscn").instantiate()
		overworld_tilemap.set_cell(cell, 0, Vector2i(11, 1))
		mirror_tilemap.set_cell(cell, 0, Vector2i(11, 1))
		fixed_lantern.global_position = to_global(overworld_tilemap.map_to_local(cell))
		add_child(fixed_lantern)

func _process(delta: float) -> void:
	if (!on_screen):
		return
		
	# Reset signal
	for cable in overworld_cables:
		overworld_tilemap.set_cell(cable, 0, overworld_cables[cable])
	for cable in mirror_cables:
		mirror_tilemap.set_cell(cable, 0, mirror_cables[cable])
	
	var last_tile = Vector2i()
	var current_tile = Vector2i()
	
	# Check if box is on pressure plate
	for plate in pressure_plates:
		generators.erase(plate)
		for box in all_boxes:
			if plate == box.tilemap.local_to_map(box.position):
				if all_boxes[box] == "crossing" || pressure_plates[plate] == all_boxes[box]:
					generators.append(plate)
	
	# Diffuse signal
	for generator in generators:
		current_tile = generator
		
		checked_cables = []
		while last_tile != current_tile:
			last_tile = current_tile # Only one adjacent tile is treated
			
			var up_tile = Vector2i(current_tile.x, current_tile.y-1)
			var down_tile = Vector2i(current_tile.x, current_tile.y+1)
			var left_tile = Vector2i(current_tile.x-1, current_tile.y)
			var right_tile = Vector2i(current_tile.x+1, current_tile.y)
			
			if (last_tile != up_tile && draw_visible_tile(up_tile, current_tile)):
				current_tile = up_tile
			if (last_tile != up_tile && draw_visible_tile(down_tile, current_tile)):
				current_tile = down_tile
			if (last_tile != up_tile && draw_visible_tile(left_tile, current_tile)):
				current_tile = left_tile
			if (last_tile != up_tile && draw_visible_tile(right_tile, current_tile)):
				current_tile = right_tile
	
	# Sensor
	solved = false
		
	for sensor in sensors:
		overworld_tilemap.set_cell(sensor, 0, Vector2i(10, 2)) # Reinitialize
		
		for tile in overworld_tilemap.get_surrounding_cells(sensor):
			var cell_atlas = overworld_tilemap.get_cell_atlas_coords(tile)
			if (cell_atlas.x in range(8, 10) && cell_atlas.y <= 5):
				overworld_tilemap.set_cell(sensor, 0, Vector2i(11, 2))
				
	if (overworld_tilemap.get_used_cells_by_id(0, Vector2(10, 2)) == []): # All sensors activated
		solved = true
		
	if solved:
		for spike in spikes:
			overworld_tilemap.set_cell(spike, 0, Vector2i(10, 3))
	else:
		for spike in spikes:
			overworld_tilemap.set_cell(spike, 0, Vector2i(11, 3))
		
func draw_visible_tile(position: Vector2i, current_tile: Vector2i) -> bool:
	var activated = false
	for lantern in get_tree().get_nodes_in_group("lantern"):
		var real_position = to_global(overworld_tilemap.map_to_local(position)) # Either tilemap give same position
				
		if checked_cables.has(position):
			return false
	
		if (lantern.is_active):
			var distance = real_position.distance_to(lantern.position)
			
			var overworld_cell_atlas = overworld_tilemap.get_cell_atlas_coords(position)
			var mirror_cell_atlas = mirror_tilemap.get_cell_atlas_coords(position)
			
			var current_cell_atlas = overworld_tilemap.get_cell_atlas_coords(current_tile)
			
			if (distance < 90 && mirror_cell_atlas.x in range(6, 8) && mirror_cell_atlas.y <= 5
			&& !current_cell_atlas.x in range(8, 10) || !current_cell_atlas.y <=5):
				mirror_tilemap.set_cell(position, 0, Vector2i(mirror_cell_atlas.x+2, mirror_cell_atlas.y))
				
			if (distance < 65 && mirror_cell_atlas.x in range(6, 8) && mirror_cell_atlas.y <= 5 ):
				mirror_tilemap.set_cell(position, 0, Vector2i(mirror_cell_atlas.x+2, mirror_cell_atlas.y))
				
			if (distance > 55):
				if (overworld_cell_atlas.x in range(6, 8) && overworld_cell_atlas.y <= 5):
					overworld_tilemap.set_cell(position, 0, Vector2i(overworld_cell_atlas.x+2, overworld_cell_atlas.y))
					
				
			if (distance < 65 && mirror_cell_atlas.x in range(6, 10) && mirror_cell_atlas.y <= 5):
				activated = true
				
			if (distance > 80 &&  overworld_cell_atlas.x in range(6, 10) && overworld_cell_atlas.y <= 5):
				activated = true
				
			if (distance > 55 && distance < 80):
				if (overworld_cell_atlas.x in range(6, 10) && overworld_cell_atlas.y <= 5
				&& mirror_cell_atlas.x in range(6, 10) && mirror_cell_atlas.y <= 5):
					activated = true
					
					if mirror_cell_atlas.x in range(6, 8):
						mirror_tilemap.set_cell(position, 0, Vector2i(mirror_cell_atlas.x+2, mirror_cell_atlas.y))
		
		else:
			var cell_atlas = overworld_tilemap.get_cell_atlas_coords(position)
			if (cell_atlas.x in range(6, 8) && cell_atlas.y <= 5):
				overworld_tilemap.set_cell(position, 0, Vector2i(cell_atlas.x+2, cell_atlas.y)) # The powered versions are two tiles away
				activated = true	
	
	checked_cables.append(position)
	return activated
		
