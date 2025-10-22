extends Marker3D
class_name Flickerer

@export var faultiness_probability = 0.5; # The Probability after one second of the light reamining on
@export var recovery_probability = 0.1; # The probability after one second of the light remaining off
@export var flicker_brightness_min = 0.2; # The percentage of brightness the light can loose before it hops back up to make

@onready var hum = $LightObject/Hum
@onready var light = $LightObject/Emitter

@onready var rng = RandomNumberGenerator.new()
@onready var start_energy = light.light_energy;

var going_out = false;

signal flicker_off
signal flicker_on

func put_out(time):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "faultiness_probability", 0.0, time);
	tween.tween_property(self, "recovery_probability", 1.0, time);
	tween.tween_callback(queue_free)

	tween.play()
	
func _process(delta: float) -> void:
	
	var r = rng.randf();
	light.light_energy += (r * 2.0 - 1.0) * 20.0 * delta
	if light.light_energy < start_energy * flicker_brightness_min or light.light_energy > start_energy / flicker_brightness_min:
		light.light_energy = start_energy
	if Utils.time_stable_rand_bool(1.0 - faultiness_probability, delta) and light.visible:
		light.visible = false
		hum.stream_paused = true
		flicker_off.emit()
		return
	if Utils.time_stable_rand_bool(1.0 - recovery_probability, delta) and not light.visible:
		light.visible = true
		hum.stream_paused = false
		flicker_on.emit()
		return
