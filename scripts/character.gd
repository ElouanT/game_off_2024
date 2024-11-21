extends CharacterBody2D

const SPEED = 150

var direction: Vector2
var has_lantern: bool = false
var lantern: Node2D
var mask: Node2D

func _ready():
	lantern = get_parent().get_node("Lantern")
	mask = lantern.get_node("Control").get_node("BackBufferCopy").get_node("Mask")

func _process(delta):
	# Basic movements
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	velocity = direction.normalized() * SPEED
	move_and_slide()

	# Query detection
	if(direction.normalized() != Vector2(0, 0)):
		$Area2D/QueryTrigger.position = direction.normalized() * 20
		
	if(has_lantern):
		lantern.position = $Sprite2D.global_position
		
	if(Input.is_action_just_pressed("action")):
		if has_lantern:
			lantern.position = $Area2D/QueryTrigger.global_position
			lantern.get_node("AnimatedSprite2D").show()
			has_lantern = false
		else:
			for area in $Area2D.get_overlapping_areas():
				if area.is_in_group("interactable"):
					if area.name == "Lantern":
						has_lantern = true
						lantern.get_node("AnimatedSprite2D").hide()
					
	if(Input.is_action_just_pressed("secondary_action")):
		if has_lantern:
			mask.visible = !mask.visible
		else:
			for area in $Area2D.get_overlapping_areas():
				if area.is_in_group("interactable"):
					if area.name == "Lantern":
						mask.visible = !mask.visible
