extends Node3D
class_name MousePlayerController

@onready var camera: Camera3D = $%Camera
@onready var player: PlayerState = $%PlayerState

@export var max_yaw = 45;
@export var max_pitch = 45 / 2.0;
@export var roll_scale = 0.25;
@export var interaction_distance: float = 4.0;
@export var camera_follow_speed = 0.5;

var current_hover;

func get_mouse_ray() -> PhysicsRayQueryParameters3D:
	var start = camera.global_position;
	var direction = camera.project_ray_normal(get_viewport().get_mouse_position())
	var query = PhysicsRayQueryParameters3D.create(start, direction * interaction_distance, Interactable.get_interaction_layer())
	query.collide_with_areas = true;

	return query

func do_camera_movement():
	var local_mouse_position = Vector2(get_viewport().get_mouse_position()) / Vector2(get_viewport().get_visible_rect().size) * 2.0 - Vector2.ONE
	rotation = Vector3(-local_mouse_position.y * deg_to_rad(max_pitch), -local_mouse_position.x * deg_to_rad(max_yaw), roll_scale * local_mouse_position.x * local_mouse_position.y * deg_to_rad(max_yaw));

func handle_interaction():

	var query = get_mouse_ray()
	player.handle_iteraction(query)

func _input(event: InputEvent) -> void:

	if event.is_action_pressed("open_inventory"):
		player.get_inventory().show_inventory()
	if event.is_action_released("open_inventory"):
		player.get_inventory().hide_inventory()

func _process(delta: float):

	handle_interaction()
	do_camera_movement()

	camera.global_basis = global_basis
	camera.position += (global_position - camera.position) * camera_follow_speed * delta

func _ready():
	camera.position = camera.global_position
	camera.top_level = true
