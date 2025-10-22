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


