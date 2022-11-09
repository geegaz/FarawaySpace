extends Node

export var shake_dir: Vector2 = Vector2.ONE
export var shake_amount: float = 0.8

onready var _Shaker: Shaker = Shaker.new()
onready var _Camera: Camera = get_viewport().get_camera()

var offset: Vector2

func _ready() -> void:
	add_child(_Shaker)

func _process(delta: float) -> void:
	_Camera.h_offset = offset.x
	_Camera.v_offset = offset.y

func shake(time: float)->void:
	_Shaker.add_shake(self, "offset", shake_dir * shake_amount, time, 70)
