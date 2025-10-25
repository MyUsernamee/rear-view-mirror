extends Node

## Given probability has that %chance after one second to return true;
## For example given f(0.5, _delta) after 1 second there is a %50 chance that it has returned true
func time_stable_rand_bool(probability, delta):
	var r = randf()
	return r < 1.0 - pow(1 - probability, delta)

## Creates a uniform normalized vector three with a equal probability for each direction on the sphere
func random_vector3():
	var yaw = randf() * 2 * PI
	var pitch = randf_range(-PI, PI)
	var y = sin(pitch);
	var xz_scale = cos(pitch);
	return Vector3(sin(yaw) * xz_scale, y, cos(yaw) * xz_scale)

## From: https://github.com/godotengine/godot-proposals/issues/10032
func get_node_aabb(node : Node3D = null, ignore_top_level : bool = true, bounds_transform : Transform3D = Transform3D()) -> AABB:
	var box : AABB
	var transform : Transform3D

	# we are going down the child chain, we want the aabb of each subsequent node to be on the same axis as the parent
	if bounds_transform.is_equal_approx(Transform3D()):
		transform = node.global_transform
	else:
		transform = bounds_transform
	
	# no more nodes. return default aabb
	if node == null:
		return AABB(Vector3(-0.2, -0.2, -0.2), Vector3(0.4, 0.4, 0.4))
	# makes sure the transform we get isn't distorted
	var top_xform : Transform3D = transform.affine_inverse() * node.global_transform

	# convert the node into visualinstance3D to access get_aabb() function.
	var visual_result : VisualInstance3D = node as VisualInstance3D
	if visual_result != null:
		box = visual_result.get_aabb()
	else:
		box = AABB()
	
	# xforms the transform with the box aabb for proper alignment I believe?
	box = top_xform * box
	# recursion
	for i in node.get_child_count():
		var child : Node3D = node.get_child(i) as Node3D
		if child && !(ignore_top_level && child.top_level):
			var child_box : AABB = get_node_aabb(child, ignore_top_level, transform)
			box = box.merge(child_box)
	
	return box

func get_time():
	return Time.get_ticks_msec()
