extends Node

export(bool) var has_started = false
export var environment: Environment

onready var _Ship: Spatial = $Ship
onready var _Spawn: Spatial = $World/Spawn

onready var _Title: Control = $UI/Title
onready var _WorldAnimationPlayer: AnimationPlayer = $WorldAnimationPlayer
onready var _WorldMusicPlayer: AudioStreamPlayer = $WorldMusicPlayer

var tween: SceneTreeTween

func _ready()->void:
	_Ship.connect("started_moving",self,"_on_Ship_started_moving")
	_Ship.teleport(_Spawn.translation, _Spawn.rotation)

func _on_Ship_started_moving() -> void:
	if has_started:
		return
	
	has_started = true
	_WorldAnimationPlayer.play("title")
	_WorldMusicPlayer.play()


func _on_Bounds_body_entered(body: Node) -> void:
	if body == _Ship:
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(environment, "fog_depth_begin", 10.0, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(environment, "fog_depth_end", 500.0, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_Bounds_body_exited(body: Node) -> void:
	if body == _Ship:
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(environment, "fog_depth_begin", 0.0, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(environment, "fog_depth_end", 1.0, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_callback(_Ship, "teleport", [_Spawn.translation, _Spawn.rotation])
		
