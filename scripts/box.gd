extends Node2D

var tilemap: TileMapLayer
var new_position: Vector2
var mirrored: bool = false
var mirror_zone_entered = 0
@export var cross = false

func _ready() -> void:
	z_index = -1
	get_child(1).set_collision_layer_value(6, false)
	get_child(1).set_collision_mask_value(6, false)
	get_child(1).set_collision_layer_value(5, true)
	get_child(1).set_collision_mask_value(5, true)
	if (mirrored):
		z_index = -2
		get_child(1).set_collision_layer_value(6, true)
		get_child(1).set_collision_mask_value(6, true)
		get_child(1).set_collision_layer_value(5, false)
		get_child(1).set_collision_mask_value(5, false)
		
	if cross:
		z_index = 2
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	for area in $Area2D.get_overlapping_areas():
		if (area.get_parent().name == "Character"):
			var character = area.get_parent()
			var inside_mirror_zone = false
			for lantern in get_tree().get_nodes_in_group("lantern"):
				if lantern.is_active && character.position.distance_to(lantern.position) <= 70:
					inside_mirror_zone = true
			
			if mirrored == inside_mirror_zone:
				for body in $Area2D.get_overlapping_bodies():
					if (body.name == "Character"):
						var destination = tilemap.local_to_map(position) + Vector2i(body.direction.normalized())
						var destination_cell_atlas = tilemap.get_cell_atlas_coords(destination)
						if (destination_cell_atlas == Vector2i(2, 1)
						|| destination_cell_atlas == Vector2i(2, 4)
						|| (destination_cell_atlas.x in range(6, 10) && destination_cell_atlas.y <= 5)
						|| (destination_cell_atlas.x in range(10, 12) && destination_cell_atlas.y <= 1)
						||	(destination_cell_atlas.x in range(10, 12) && destination_cell_atlas.y == 5)):
							new_position = tilemap.map_to_local(destination)
	position = lerp(position, new_position, 8 * delta)

func enter_mirror_zone():
	mirror_zone_entered += 1
	mirrored = true
	tilemap = get_parent().get_node("Tilemaps").get_node("MirrorWorld")
	get_child(1).set_collision_layer_value(6, true)
	get_child(1).set_collision_mask_value(6, true)
	get_child(1).set_collision_layer_value(5, false)
	get_child(1).set_collision_mask_value(5, false)

func leave_mirror_zone():
	mirror_zone_entered -= 1
	if (mirror_zone_entered == 0):
		mirrored = false
		tilemap = get_parent().get_node("Tilemaps").get_node("Overworld")
		get_child(1).set_collision_layer_value(5, true)
		get_child(1).set_collision_mask_value(5, true)
		get_child(1).set_collision_layer_value(6, false)
		get_child(1).set_collision_mask_value(6, false)
