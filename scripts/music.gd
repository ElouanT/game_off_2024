extends Node2D

@export var loop_start: float
@export var loop_end: float
var overworld_stream: AudioStreamPlayer2D
var mirror_stream: AudioStreamPlayer2D
var transition: AnimationPlayer

func _ready() -> void:
	overworld_stream = $OverworldStream
	mirror_stream = $MirrorStream
	transition = $AnimationPlayer
	overworld_stream.play()
	mirror_stream.play()
	mirror_stream.volume_db = -80
	
func _process(delta: float) -> void:
	var position = overworld_stream.get_playback_position() + AudioServer.get_time_since_last_mix()
	if (position >= loop_end):
		overworld_stream.seek(loop_start)
		mirror_stream.seek(loop_start)
		
func mirror_transition():
	transition.play("mirror_transition")
	
func overworld_transition():
	transition.play("overworld_transition")
		
