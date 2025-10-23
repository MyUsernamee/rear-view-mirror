extends Node3D
class_name MousePlayerController

@onready var camera: Camera3D = $%Camera
@onready var player: PlayerState = $%PlayerState

@export var max_yaw = 45;
@export var max_pitch = 45 / 2.0;
@export var interaction_distance: float = 4.0;

var current_hover;

func get_mouse_ray() -> PhysicsRayQueryParameters3D:
	var start = camera.global_position;
	var direction = camera.project_ray_normal(get_viewport().get_mouse_position())
	var query = PhysicsRayQueryParameters3D.create(start, direction * interaction_distance, Interactable.get_interaction_layer())
	query.collide_with_areas = true;

	return query

func do_camera_movement():
	var local_mouse_position = Vector2(get_viewport().get_mouse_position()) / Vector2(get_viewport().size) * 2.0 - Vector2.ONE
	camera.rotation = Vector3(-local_mouse_position.y * deg_to_rad(max_pitch), -local_mouse_position.x * deg_to_rad(max_yaw), 0.0);

func handle_interaction():

	var query = get_mouse_ray()
	player.handle_iteraction(query)

func _process(delta: float):

	handle_interaction()
	do_camera_movement()
