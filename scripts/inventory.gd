extends Node
class_name Inventory

const ITEM_COUNT = 4

signal on_item_added(item: Item)
signal on_item_removed(item: Item)
signal on_selected_item_changed(item: Item)

var inventory: Array[Item];
var item_slots: Array[Node3D];
var selected_item: int = 0;

@onready var item_wheel = $%ItemWheel
@onready var item_viewport = $%InventoryContainer
@onready var item_name: Label = $%ItemName

# Returns the current held item, or null if nothing is currently held
func get_selected_item() -> Item:
	return (inventory[selected_item] if not inventory.is_empty() and selected_item < inventory.size() else null)

func has_item(item: Item) -> bool:
	return self.inventory.has(item)

## Remove the item at the given index in the inverntory and shift the others down.
func remove_item(index):
	if index > inventory.size() or inventory.size() == 0:
		return ;

	var item_to_remove = inventory[index]

	item_slots[index].get_child(0).queue_free()
	for new_index in range(index, inventory.size() - 1):
		inventory[new_index] = inventory[new_index + 1]
		var next_item = item_slots[new_index + 1].get_child(0);
		item_slots[new_index + 1].remove_child(next_item)

		item_slots[new_index].add_child(next_item)

	inventory.pop_back();

	on_item_removed.emit(item_to_remove);

	if selected_item >= index:
		on_selected_item_changed.emit(inventory[selected_item])

	selected_item = min(inventory.size(), selected_item)

func take_current_item():
	if selected_item > inventory.size() or inventory.is_empty():
		return

	var new_item = inventory[selected_item]
	remove_item(selected_item);

	return new_item;

func is_holding_item_type(item: ItemResource):
	return selected_item < inventory.size() and item == inventory[selected_item].item_descriptor;

func is_holding_item():
	return selected_item < inventory.size() and inventory[selected_item] != null

func add_item(item: Item) -> bool:
	if inventory.size() >= ITEM_COUNT:
		return false

	# Add a display node for the item, and set its display
	var index = inventory.size();
	inventory.append(item);
	item.get_parent().remove_child(item)

	var view_model = item.item_descriptor.view_model

	if not view_model:
		push_warning("View model not defined for: " + item.item_descriptor.id)
	else:
		var view_model_instance = view_model.instantiate()
		item_slots[index].add_child(view_model_instance)

	on_item_added.emit(item);

	return true

func get_item(index: int) -> Item:
	if index < 0 or index >= inventory.size():
		return null
	return inventory[index]

func show_inventory():
	item_viewport.visible = true;

func hide_inventory():
	item_viewport.visible = false;
# If the inventory should be shown, this function should be called
func update_inventory_screen(delta):
	if not item_viewport.visible:
		return 

	var scroll_amount = sign(Input.is_action_just_pressed("inventory_next") as int - (Input.is_action_just_pressed("inventory_back") as int))
	selected_item = posmod(selected_item + scroll_amount, ITEM_COUNT);

	item_wheel.basis = item_wheel.basis.slerp(Basis(Vector3.UP, TAU / ITEM_COUNT * selected_item), 5.0 * delta);

	for item in ITEM_COUNT:
		item_slots[item].rotate_y(delta);

	if selected_item < inventory.size() and not inventory.is_empty():
		item_name.text = inventory[selected_item].item_descriptor.name
	else:
		item_name.text = ""

	if scroll_amount != 0 and selected_item < inventory.size():
		if selected_item < inventory.size():
			on_selected_item_changed.emit(inventory[selected_item])
		else:
			on_selected_item_changed.emit(null)

func _ready():

	var angle_per_item = TAU / ITEM_COUNT

	# We add item count in a circle
	for item in ITEM_COUNT:

		var slot = Node3D.new()
		slot.position = Vector3(sin(angle_per_item * item), 0.0, -cos(angle_per_item * item))
		slot.rotate_x(PI / 4.0);
		slot.scale *= 0.25;

		item_wheel.add_child(slot)
		item_slots.append(slot);

func _process(delta: float):

	update_inventory_screen(delta)
