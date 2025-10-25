extends Node3D
class_name Jiggler

@export var jiggle_speed = 1.0;
@export var jiggle_scale = Vector3.ONE

var noise = FastNoiseLite.new()

func _process(_delta: float) -> void:
	var t = Utils.get_time() * jiggle_speed
	noise.seed = 0
	var x = noise.get_noise_1d(t);
	noise.seed += 1
	var y = noise.get_noise_1d(t);
	noise.seed += 1
	var z = noise.get_noise_1d(t);
	position = Vector3(x, y, z) * jiggle_scale
