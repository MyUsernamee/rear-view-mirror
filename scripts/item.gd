extends Interactable
class_name Item

const DROP_RAY_DISTANCE = 999.0

@export var item_descriptor: ItemResource;

signal on_key_event(event) ## Fired when a key is pressed while this item_descriptor is being held
signal on_mouse_event(event) ## Fired when a key is pressed while this item_descriptor is being held
signal on_drop()

func make_interactable():
	collision_layer = 0b00000010

func make_non_interactable():
	collision_layer = 0

func _ready() -> void:
	on_hover.connect(_on_hover)
	on_interact.connect(_on_interact)
	stop_hover.connect(_stop_hover)
	on_drop.connect(_on_drop)

func _on_interact():
	Game.display("")
	Game.get_player().add_item(self);

func _on_hover():
	Game.display("Pickup " + item_descriptor.name + ": [" + InputMap.action_get_events("interact")[0].as_text().to_upper() + "]")

func _stop_hover():
	Game.display("");

func _on_drop():
	# Default behavior is to snap to ground
	var query = PhysicsRayQueryParameters3D.create(global_position, global_position - Vector3.UP * DROP_RAY_DISTANCE, 0b1, [self])
	var result = get_world_3d().direct_space_state.intersect_ray(query)

	if result:
		global_position = result.position
