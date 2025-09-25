class_name Tutorial
extends Node3D

@export var start_fade: float = 0.0 # (float, 0.0, 1.0)
@export var tutorial_material: ShaderMaterial
@export var visibility: NodePath
@export var icon: NodePath
@export var mesh_instances: Array # (Array, NodePath)

var tween: Tween
var fade: float = 0.0

@onready var _Icon: Sprite3D = get_node_or_null(icon)
@onready var _VisibilityNotifier: VisibleOnScreenNotifier3D = get_node_or_null(visibility)

func _ready() -> void:
	for node_path in mesh_instances:
		var node: MeshInstance3D = get_node_or_null(node_path)
		if node:
			node.material_override = tutorial_material
	
	if _VisibilityNotifier:
		_VisibilityNotifier.connect("screen_entered", Callable(self, "_on_VisibilityNotifier_screen_entered"))
		_VisibilityNotifier.connect("screen_exited", Callable(self, "_on_VisibilityNotifier_screen_exited"))
	
	set_fade(start_fade)
	if _VisibilityNotifier.is_on_screen():
		fade_in(1.0)

func fade_in(duration: float, delay: float = 0.0)->void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_interval(delay)
	tween.tween_method(Callable(self, "set_fade"), fade, 1.0, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func fade_out(duration: float, delay: float = 0.0)->void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_interval(delay)
	tween.tween_method(Callable(self, "set_fade"), fade, 0.0, duration).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func set_fade(value: float)->void:
	fade = value
	if tutorial_material:
		var color: Color = tutorial_material.get_shader_parameter("modulate")
		color.a = value
		tutorial_material.set_shader_parameter("modulate", color)
	if _Icon:
		_Icon.modulate.a = value


func _on_VisibilityNotifier_screen_entered() -> void:
	fade_in(2.0, 0.2)


func _on_VisibilityNotifier_screen_exited() -> void:
	fade_out(1.0)
