class_name ThreadLink
extends Node

@export var length: int = 100
@export var points_spacing: float = 1.0
@export var target: Node3D # TODO

@export_group("References")
@export var thread_start: ThreadTrigger
@export var thread_end: ThreadTrigger
@export var thread_line: Line3D

var linking: bool
var last_point: Vector3
var length_used: int

var ship: Ship

func _enter_tree() -> void:
	thread_start.entered.connect(_on_thread_start_entered)
	thread_end.entered.connect(_on_thread_end_entered)

func _exit_tree() -> void:
	thread_start.entered.disconnect(_on_thread_start_entered)
	thread_end.entered.disconnect(_on_thread_end_entered)

func _ready() -> void:
	thread_start.active = true
	thread_end.active = false
	set_process(false)

func _process(delta: float) -> void:
	var pos: = ship.global_position
	if pos.distance_to(last_point) > points_spacing:
		length_used += 1
		print("Added 1 point (%s/%s)"%[length_used, length])
		if length_used >= length:
			cancel_linking()
			return # Skip the rest of the process function
		thread_line.points.append(pos)
		last_point = pos
	
	# Move last point to the ship's position
	# TODO: Should probably use an anchor ?
	thread_line.points[-1] = ship.global_position
	thread_line.rebuild()

func _on_thread_start_entered(entered_ship: Ship)->void:
	if linking:
		return # Skip if currently linking
	print("Started linking")
	ship = entered_ship
	thread_start.active = false
	last_point = thread_start.global_position
	thread_line.clear()
	thread_line.points.append(last_point)
	thread_line.points.append(ship.global_position)
	linking = true
	set_process(true)

func _on_thread_end_entered(entered_ship: Ship)->void:
	if linking and entered_ship == ship:
		print("Finished linking")
		thread_end.active = true
		# TODO: Should probably use an anchor ?
		thread_line.points[-1] = thread_end.global_position
		linking = false
		set_process(false)
		
		# TODO: call method

func cancel_linking()->void:
	if not linking:
		return
	print("Canceled linking")
	# TODO: clear points and reset states
	length_used = 0
	thread_line.clear()
	thread_start.active = true
	thread_end.active = false
	linking = false
	set_process(false)
