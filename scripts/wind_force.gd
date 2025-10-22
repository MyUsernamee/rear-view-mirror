extends RigidBody3D

@export var multiplier = 5.0;
@export var noise_speed = 10.0;
@export var gust_factor = 4.0;
@export var damping_factor = 0.4;

@onready var noise = FastNoiseLite.new()

func _physics_process(delta: float) -> void:
	var f_x = noise.get_noise_3dv(global_position + Vector3.FORWARD * Time.get_ticks_msec() / 1000.0 * noise_speed) ** gust_factor ;
	var f_z = noise.get_noise_3dv(global_position + Vector3.UP * Time.get_ticks_msec() / 1000.0 * noise_speed) ** gust_factor ;
	apply_force(Vector3(f_x, 0.0, f_z) * multiplier)

	linear_velocity -= linear_velocity * (damping_factor * delta)

	# DebugDraw3D.draw_line(global_position, global_position + Vector3(f_x, 0.0, f_z) * multiplier, Color(1, 0, 0), 1)
