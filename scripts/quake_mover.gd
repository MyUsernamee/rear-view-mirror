extends CharacterBody3D
class_name QuakeMover

const MAX_AIR_SPEED = 0.5
const FRICTION = 40

@onready var step_sound: AudioStreamPlayer3D = $%StepSound

var wish_dir = Vector3.ZERO;

var walk_speed = 3
var sprint_speed = 10
var max_accel = 20 * sprint_speed

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var sprinting = false;

var distance_walked = 0.0

func step_function(x):
	return abs(sin(x / PI / 2))
func step_prime(x):
	return sin(x / PI) / (4 * PI * abs(sin(x / (2 * PI))))

func do_step_sound(delta):

	if (fmod(distance_walked * PI / 2.0, PI) + delta * velocity.length() * PI / 2.0) > PI:
		# Play step sound
		step_sound.play()


func friction(vel: Vector3, delta):
	
	return vel - (vel * Vector3(1, 0, 1)).normalized() * min(vel.length(), FRICTION * delta)

func update_vel_ground(wishdir: Vector3, vel: Vector3, MAX_SPEED: float, delta: float) -> Vector3:
	vel = friction(vel, delta)

	var current_speed = vel.dot(wishdir)
	var add_speed = clamp(MAX_SPEED - current_speed, 0, max_accel * delta)

	return vel + add_speed * wishdir

func update_vel_air(wishdir: Vector3, vel: Vector3, delta: float) -> Vector3:

	var current_speed = vel.dot(wishdir)
	var add_speed = clamp(MAX_AIR_SPEED - current_speed, 0, max_accel * delta)

	return vel + add_speed * wishdir

## Get the change in velocity given the current wish_dir
## Useful for npc's or prediction
func get_accel(delta: float) -> Vector3:
	
	var new_velocity = Vector3(velocity);

	if not is_on_floor():
		new_velocity.y -= gravity * delta

	if is_on_floor():
		new_velocity = update_vel_ground(wish_dir, new_velocity, sprint_speed if sprinting else walk_speed, delta);
	else:
		new_velocity = update_vel_air(wish_dir, new_velocity, delta);
	
	return (new_velocity - velocity) / delta

func integrate_acceleration(acceleration: Vector3, delta: float):
	velocity += acceleration * delta
	distance_walked += velocity.length() * delta

func do_vel(delta: float) -> void:
	var acceleration = get_accel(delta)
	integrate_acceleration(acceleration, delta)
