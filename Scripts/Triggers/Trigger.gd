class_name Trigger
extends Area

export var debug_wire_color: Color = Color(1.0, 1.0, 1.0, 1.0)
export var debug_solid_color: Color = Color(1.0, 1.0, 1.0, 0.2)

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

func _process(delta: float) -> void:
	Debug.draw_cube(global_transform, debug_solid_color)
	Debug.draw_wire_cube(global_transform, debug_wire_color)

func _on_body_entered(body: Node)->void:
	if body is Ship:
		trigger_entered(body)

func _on_body_exited(body: Node)->void:
	if body is Ship:
		trigger_exited(body)


func trigger_entered(ship: Ship)->void:
	pass # Override in children

func trigger_exited(ship: Ship)->void:
	pass # Override in children
