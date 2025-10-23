extends CollisionObject3D
class_name Interactable

const INTERACTABLE_COLLISION_LAYER = 0b10; # Layer 2

signal on_interact
signal stop_hover
signal on_hover

static func get_interaction_layer():
	return INTERACTABLE_COLLISION_LAYER
