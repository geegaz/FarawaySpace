tool
extends Spatial

export var create_bodies: bool = false setget _create_bodies
# Rigidbody parameters
export var rigidbody_mass: float = 1.0
export var rigidbody_mass_from_size: bool = true

func create():
	var shape: Shape
	var col_shape: CollisionShape
	var rigidbody: RigidBody
	
	var volume_size: float
	var children: = get_children()
	for child in children:
		if child is MeshInstance:
			rigidbody = RigidBody.new()
			col_shape = CollisionShape.new()
			shape = child.mesh.create_convex_shape(true, true)
			volume_size = child.get_aabb().size.length()
			
			col_shape.shape = shape
			rigidbody.mass = rigidbody_mass
			if rigidbody_mass_from_size:
				rigidbody.mass *= volume_size
			
			add_child(rigidbody)
			remove_child(child)
			rigidbody.add_child(col_shape)
			rigidbody.add_child(child)
			rigidbody.transform = child.transform
			child.transform = Transform.IDENTITY
			
			if Engine.editor_hint:
				rigidbody.set_owner(get_tree().edited_scene_root)
				col_shape.set_owner(get_tree().edited_scene_root)
				child.set_owner(get_tree().edited_scene_root)
			else:
				rigidbody.set_owner(self)
				col_shape.set_owner(rigidbody)
				child.set_owner(rigidbody)

func _create_bodies(_value: bool):
	create_bodies = false
	if is_inside_tree():
		create()
