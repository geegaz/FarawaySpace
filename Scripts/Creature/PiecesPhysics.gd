tool
extends Spatial

export var set_physics: bool = false setget _set_physics
# Rigidbody parameters
export var rigidbody_mass: float = 1.0
export var rigidbody_mass_from_size: bool = true
export var rigidbody_gravity_scale: float = 1.0
export var rigidbody_contacts: int = 0
export(int, LAYERS_3D_PHYSICS) var rigidbody_layer: int = 1
export(int, LAYERS_3D_PHYSICS) var rigidbody_mask: int = 1
# Other parameters
export var attach_script: Script = preload("res://Scripts/Creature/CreaturePiece.gd")

func create():
	var children: = get_children()
	for child in children:
		if child is MeshInstance:
			create_single(child)
	set_script(null)

func create_single(instance: MeshInstance):
	var rigidbody: = RigidBody.new()
	var col_shape: = CollisionShape.new()
	var shape: = instance.mesh.create_convex_shape(true, true)
	
	col_shape.shape = shape
	rigidbody.collision_layer = rigidbody_layer
	rigidbody.collision_mask = rigidbody_mask
	rigidbody.mass = rigidbody_mass
	if rigidbody_mass_from_size:
		var volume_size: = instance.get_aabb().size.length()
		rigidbody.mass *= volume_size
	if rigidbody_contacts > 0:
		rigidbody.contact_monitor = true
		rigidbody.contacts_reported = rigidbody_contacts
	if attach_script:
		rigidbody.set_script(attach_script)
	
	add_child(rigidbody)
	remove_child(instance)
	rigidbody.add_child(col_shape)
	rigidbody.add_child(instance)
	rigidbody.transform = instance.transform
	instance.transform = Transform.IDENTITY
	
	if Engine.editor_hint:
		rigidbody.set_owner(get_tree().edited_scene_root)
		col_shape.set_owner(get_tree().edited_scene_root)
		instance.set_owner(get_tree().edited_scene_root)
	else:
		rigidbody.set_owner(self)
		col_shape.set_owner(rigidbody)
		instance.set_owner(rigidbody)

func _set_physics(_value: bool):
	set_physics = false
	if Engine.editor_hint and is_inside_tree():
		create()

#func get_rigidbodies(parent: Node = self)->Array:
#	var bodies: = []
#	for child in get_children():
#		if child is RigidBody:
#			bodies.append(child)
#	return bodies
#
#func get_meshinstances(parent: Node = self)->Array:
#	var instances: = []
#	for child in get_children():
#		if child is MeshInstance:
#			instances.append(child)
#	return instances
