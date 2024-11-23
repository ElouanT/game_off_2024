extends Node2D

var is_active: bool = false

func flip():
	if (is_active):
		$AnimatedSprite2D.play("off")
		disable()
	else:
		$AnimatedSprite2D.play("on")
		enable()

func enable():
	is_active = true
	$Control/BackBufferCopy/Mask.visible = true
	$MirrorZone/CollisionShape2D.disabled = false
	
func disable():
	is_active = false
	$Control/BackBufferCopy/Mask.visible = false
	$MirrorZone/CollisionShape2D.disabled = true


func _on_mirror_zone_body_entered(body: Node2D) -> void:
	if(body.name == "Character"):
		body.enter_mirror_zone()


func _on_mirror_zone_body_exited(body: Node2D) -> void:
	if(body.name == "Character"):
		body.leave_mirror_zone()
