extends CharacterBody2D

const SPEED = 150

var direction: Vector2
var has_lantern: bool = false
var lantern: Node2D
var mirror_zone_entered: int = 0

var music: Node2D

func _ready():
	lantern = get_parent().get_node("Lantern")
	music = get_parent().get_node("Music")

func _process(delta):
	# Basic movements
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	velocity = direction.normalized() * SPEED
	move_and_slide()
	
	# Animation
	if(direction.x != 0):
		$AnimatedSprite2D.flip_h = direction.x > 0
	
	if(direction.normalized() == Vector2(0, 0)):
		$AnimatedSprite2D.pause()
		
	if(direction.x != 0 && direction.y == 0):
		$AnimatedSprite2D.play("left")
	if(direction.y < 0):
		$AnimatedSprite2D.play("up")
	if(direction.y > 0):
		$AnimatedSprite2D.play("down")

	# Query detection
	if(direction.normalized() != Vector2(0, 0)):
		$Area2D/QueryTrigger.position = direction.normalized() * 20
		
	if(has_lantern):
		lantern.position = $AnimatedSprite2D.global_position
		
	if(Input.is_action_just_pressed("action")):
		if has_lantern:
			lantern.position = $Area2D/QueryTrigger.global_position
			lantern.get_node("AnimatedSprite2D").scale = Vector2(1, 1)
			has_lantern = false
			lantern.get_node("StaticBody2D").get_child(0).set_deferred("disabled", false)
		else:
			for area in $Area2D.get_overlapping_areas():
				if area.is_in_group("interactable"):
					if area.name == "Lantern":
						has_lantern = true
						lantern.get_node("StaticBody2D").get_child(0).set_deferred("disabled",true)
						lantern.get_node("AnimatedSprite2D").scale = Vector2(0.9, 0.8)
					
	if(Input.is_action_just_pressed("secondary_action")):
		if has_lantern:
			lantern.flip()
		else:
			for area in $Area2D.get_overlapping_areas():
				if area.is_in_group("interactable"):
					area.get_parent().flip()
						
func enter_mirror_zone():
	mirror_zone_entered += 1
	set_collision_layer_value(6, true)
	set_collision_mask_value(6, true)
	set_collision_layer_value(5, false)
	set_collision_mask_value(5, false)
	
	if (mirror_zone_entered == 1):
		music.mirror_transition()

func leave_mirror_zone():
	mirror_zone_entered -= 1
	if (mirror_zone_entered == 0):
		music.overworld_transition()
		set_collision_layer_value(5, true)
		set_collision_mask_value(5, true)
		set_collision_layer_value(6, false)
		set_collision_mask_value(6, false)
