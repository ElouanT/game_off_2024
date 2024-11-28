extends Node2D

var tilemap: TileMapLayer
var new_position: Vector2
var mirrored: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	z_index = -1
	if (mirrored):
		z_index = -2
		get_child(1).set_collision_layer_value(6, true)
		get_child(1).set_collision_mask_value(6, true)
		get_child(1).set_collision_layer_value(5, false)
		get_child(1).set_collision_mask_value(5, false)
	
	for area in $Area2D.get_overlapping_areas():
		if (area.get_parent().name == "Character"
		&& mirrored == get_parent().get_parent().get_node("Lantern").is_active):
			for bodie in $Area2D.get_overlapping_bodies():
				var destination = tilemap.local_to_map(position) + Vector2i(bodie.direction.normalized())
				var destination_cell_atlas = tilemap.get_cell_atlas_coords(destination)
				if (destination_cell_atlas == Vector2i(2, 1)
				|| destination_cell_atlas == Vector2i(2, 4)
				|| (destination_cell_atlas.x in range(6, 10) && destination_cell_atlas.y <= 5)
				|| (destination_cell_atlas.x in range(10, 12) && destination_cell_atlas.y <= 1)
				||	(destination_cell_atlas.x in range(10, 12) && destination_cell_atlas.y == 5)):
					new_position = tilemap.map_to_local(destination)
	position = lerp(position, new_position, 8 * delta)
