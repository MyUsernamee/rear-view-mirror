extends QuakeMover
class_name FirstPersonPlayerController

const PLAYER_HEIGHT = 1
const CAMERA_HEIGHT = 0.75
const EXHAUSTION_SPEED = 1.0 / 5.0
const INTERACTION_DISTANCE = 4.0
const DROP_ITEM_HEIGHT = 0.25

@export var sensitivity = 0.01;
@export var JUMP_VELOCITY = 4.5
@export var footstep_stream: AudioStream;

@onready var camera: Camera3D = $%Camera;
@onready var root_camera: Camera3D = $%Camera;
@onready var camera_root: Marker3D = $%CameraRoot;
@onready var ears: RaytracedAudioListener = $%Ears
@onready var noise_sound = $Noise
@onready var stamina_bar = $Control/StaminaBar
@onready var hand = $%Hand;
@onready var hand_container = hand.get_node("../HandContainer")
@onready var player: Player = $%Player
@onready var inventory: Inventory = $%Player/%Inventory

var mouse_velocity = Vector2(0.0, 0.0)
var current_hover: Interactable;
var stamina = 1.0;
var exhausted = false

var camera_captured = false;

func can_sprint():
	return not exhausted and stamina > 0.0

func drop_current_item():

	var new_item = inventory.take_current_item()
	if new_item == null:
		return;
	new_item.reparent(get_parent())	
	new_item.rotation = Vector3.ZERO
	new_item.process_mode = Node.PROCESS_MODE_INHERIT
	new_item.show()

	var query = PhysicsRayQueryParameters3D.create(camera_root.global_position, -camera_root.global_basis.z * INTERACTION_DISTANCE + camera_root.global_position, 0b1, [self])
	var state_space = get_world_3d().direct_space_state
	var result = state_space.intersect_ray(query)

	if result:
		new_item.global_position = result.position + Vector3.UP * DROP_ITEM_HEIGHT
	else:
		new_item.global_position = -camera_root.global_basis.z * INTERACTION_DISTANCE + camera_root.global_position

	new_item.global_rotation = Vector3.UP * camera_root.global_rotation;
	new_item.call_deferred("emit_signal", "on_drop")

func _physics_process(delta):

	if camera_captured:
		return
	# Add the gravity.
	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		wish_dir = direction
	else:
		wish_dir = Vector3.ZERO

	sprinting = Input.is_action_pressed("sprint") and can_sprint()

	do_vel(delta);
	move_and_slide()

func do_camera_movement():
	
	# View angling
	transform.basis = transform.basis.rotated(Vector3.UP, -mouse_velocity.x * sensitivity);
	camera_root.transform.basis = camera_root.transform.basis.rotated(Vector3.RIGHT, -mouse_velocity.y * sensitivity);
	camera_root.position.y = CAMERA_HEIGHT + 0.1 * abs(sin(distance_walked * PI / 2.0))
	mouse_velocity = Vector2(0.0, 0.0)

	var y_dot = camera_root.transform.basis.y.dot(transform.basis.y)
	if y_dot < 0:
		# Camera is rotated too far, fix it
		var z_dot = camera_root.transform.basis.z.dot(transform.basis.y)
		camera_root.transform.basis.z = transform.basis.y * z_dot
		# TODO: What the hell
		camera_root.transform.basis.y = (camera_root.transform.basis.y * (Vector3(1, 0, 1))).normalized() 

func handle_items():
	var state = get_world_3d().direct_space_state
	
	var query = PhysicsRayQueryParameters3D.create(camera_root.global_position, camera_root.global_transform * (Vector3.FORWARD * INTERACTION_DISTANCE), 0b10)
	query.collide_with_areas = true;
	var result = state.intersect_ray(query)

	if result and result["collider"] is Interactable:
		var hit = result["collider"];

		hit.on_hover.emit()

		current_hover = hit

	elif current_hover != null:
		current_hover.stop_hover.emit();
		current_hover = null

	if current_hover and Input.is_action_just_pressed("interact"):
		current_hover.on_interact.emit()
		current_hover = null

func handle_sprinting(delta):
	if sprinting:
		stamina -= delta * EXHAUSTION_SPEED
		
		if stamina <= 0:
			exhausted = true

	else:
		stamina = min(stamina + delta * EXHAUSTION_SPEED, 1.0)

	if exhausted and stamina == 1.0:
		exhausted = false

	stamina_bar.value = stamina
	stamina_bar.visible = stamina != 1.0

# Updates the view model for the currently held item
func refresh_held_item(new_item: Item):
	for child in hand.get_children():
		child.queue_free();
	hand.add_child(new_item.item_descriptor.view_model.instantiate())


func create_footstep():
	var footstep_audio_stream = AudioStreamPlayer3D.new()
	footstep_audio_stream.stream = footstep_stream;
	get_node("/root/World").add_child(footstep_audio_stream)

func take_camera():
	if camera_captured:
		return

	camera_captured = true
	camera.top_level = true

	return camera

func release_camera():
	if not camera_captured:
		return

	camera.top_level = false
	camera.transform = Transform3D.IDENTITY;

	camera_captured = false

func _process(delta):

	if camera_captured:
		return

	do_step_sound(delta)
	do_camera_movement()
	handle_items()
	handle_sprinting(delta)


func _input(event):

	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
		if event.is_action_pressed('open_inventory'):
			inventory.show_inventory()
		if event.is_action_released('open_inventory'):
			inventory.hide_inventory()

	if event is InputEventMouseMotion:
		mouse_velocity = event.relative

	var current_item = inventory.get_held_item()

	if event is InputEventMouseButton:
		if current_item:
			current_item.on_mouse_event.emit(event)

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	inventory.on_selected_item_changed.connect(refresh_held_item)
