class_name NodePool extends Node

export var override_parent: NodePath
export var original: PackedScene
export var amount: int = 100

var available: = []
var active: = []

var parent: Node = self

func _ready():
	if original:
		create_pool(original, get_node_or_null(override_parent))

func pull()->Node:
	var new_node: Node = available.pop_back()
	if new_node:
		active.append(new_node)
		# Enable the node
		new_node.set_process(true)
		new_node.set_physics_process(true)
	else:
		new_node = active.front()
	return new_node

func push(node: Node):
	var node_index: int = active.find(node)
	if node_index >= 0:
		active.remove(node_index)
		available.append(node)
		# Disable the node
		node.set_process(false)
		node.set_physics_process(false)

func clear_pool():
	var node: Node
	# Clear available nodes
	node = available.pop_back()
	while node:
		node.queue_free()
		node = available.pop_back()
	# Clear active nodes
	node = active.pop_back()
	while node:
		node.queue_free()
		node = active.pop_back()

func create_pool(scene: PackedScene, new_parent: Node = null):
	clear_pool()
	var node: Node
	# Create all the nodes in the pool
	original = scene
	if new_parent:
		parent = new_parent
	for i in amount:
		node = original.instance()
		available.append(node)
		parent.add_child(node)
		# Disable the node for now
		node.set_process(false)
		node.set_physics_process(false)

func connect_pool(_signal: String, _object: Object, _method: String, _binds: Array = [], _flags: int = 0):
	for node in available:
		node.connect(_signal, _object, _method, _binds, _flags)
	for node in active:
		node.connect(_signal, _object, _method, _binds, _flags)

func disconnect_pool(_signal: String, _object: Object, _method: String):
	for node in available:
		node.disconnect(_signal, _object, _method)
	for node in active:
		node.disconnect(_signal, _object, _method)
