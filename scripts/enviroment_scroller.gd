extends Node3D
class_name EnviromentScroller

@export var target_length = 100.0; ## The length the road needs to be behind and in front of the scroller
@export var envrioment_segment: PackedScene;

@export var segment_length: float = 0.0;

var local_scroll_amount;
var scroll_amount: float = 0.0:
	set(value):
		local_scroll_amount = fposmod(value, get_length_segment())
		scroll_amount = value
		position.z = local_scroll_amount;
	get:
		return scroll_amount

func calculate_segment_length():
	var test_segment = envrioment_segment.instantiate()
	add_child(test_segment)
	segment_length = Utils.get_node_aabb(test_segment).size.z
	test_segment.queue_free()

func get_length_segment():
	return segment_length

func get_num_segments():
	return ceil(target_length / get_length_segment())

func _ready():
	
	if segment_length == 0.0:
		calculate_segment_length()

	for index in range(get_num_segments()):
		var segment: Node3D = envrioment_segment.instantiate();
		add_child(segment)
		segment.position = Vector3.FORWARD * (index * get_length_segment() - target_length / 2.0);

func _process(delta: float) -> void:
	scroll_amount += delta * 40.0;
