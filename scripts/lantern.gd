extends Node2D

var is_active: bool = false

func flip():
	if (is_active):
		disable()
	else:
		enable()

func enable():
	is_active = true
	$Control/BackBufferCopy/Mask.visible = true
	$MirrorZone/CollisionShape2D.disabled = false
	$Contour.visible = true
	$Control/BackBufferCopy/MaskAnimation.play("lantern_on")
	$AnimatedSprite2D.play("on")
	$Sounds/On.play()
	
func disable():
	is_active = false
	$Contour.visible = false
	$Control/BackBufferCopy/Mask.visible = false
	$MirrorZone/CollisionShape2D.disabled = true
	$AnimatedSprite2D.play("off")
	$Sounds/Off.play()


func _on_mirror_zone_body_entered(body: Node2D) -> void:
	if(body.name == "Character"):
		body.enter_mirror_zone()


func _on_mirror_zone_body_exited(body: Node2D) -> void:
	if(body.name == "Character"):
		body.leave_mirror_zone()


func _on_mirror_zone_area_entered(area: Area2D) -> void:
	if(area.get_parent().name == "CrossingBox"):
		area.get_parent().enter_mirror_zone()


func _on_mirror_zone_area_exited(area: Area2D) -> void:
	if(area.get_parent().name == "CrossingBox"):
		area.get_parent().leave_mirror_zone()
