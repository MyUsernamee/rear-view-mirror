extends Node3D
class_name PlayerState
## Simply holds the player state, mainly the inventory, but can hold other things through extending this class.
## The reason this was refactored out of the first person player controller class was so if we decide to change controllers.
## Say from a stationary to a quake mover based one, we don't need to have werid code to manage moving player state.
## You can just simply move the node. The controllers then simply manage moving the player around and interaction.
## Nicely, though, as this is a Node3D, it still functions almost the exact same as before minus some slight changes.
## The only big thing you might have to worry about now is how the UI is managed. It is now under the Game, except for the inventory and
## Ui needed specifcally for a certain object, i.e. non global ui.

@onready var inventory = $%Inventory;

var current_hover;

func handle_iteraction(ray_query):

	var result = get_world_3d().direct_space_state.intersect_ray(ray_query);
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

func get_inventory() -> Inventory:
	return inventory;

func _ready():
	Game.set_player(self)
