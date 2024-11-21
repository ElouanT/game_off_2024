extends Area2D

const ACCELERATION = 10
var entered: bool = false
var camera_anchor: Vector2
var camera_position: Vector2

func _on_body_entered(body):
	camera_anchor = get_parent().get_node("CameraOrigin").global_position
	camera_position = get_viewport().get_camera_2d().transform.origin
	entered = true
	# get_viewport().get_camera_2d().transform.origin = get_parent().get_node("CameraOrigin").global_position

func _on_body_exited(body: Node2D) -> void:
	entered = false

func _process(delta: float) -> void:
	if (entered):
		camera_position = get_viewport().get_camera_2d().transform.origin
		camera_position = lerp(camera_position, camera_anchor, ACCELERATION * delta)
		get_viewport().get_camera_2d().transform.origin = camera_position
