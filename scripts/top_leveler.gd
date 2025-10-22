extends PhysicsBody3D

@export var follow_parent = false;
func _ready():
	var global_trans = Transform3D(global_transform)
	top_level = true		
	global_transform = global_trans

func _process(delta: float) -> void:
	if follow_parent:
		global_transform = get_parent().global_transform
