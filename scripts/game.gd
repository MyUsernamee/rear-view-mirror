extends Node3D

const DEBUG = false;

@onready var world = $/root/World;
@onready var vhs_effect: ShaderMaterial = get_node( "/root/World/%VHS" ).material
@onready var environment: WorldEnvironment = get_node("/root/World/%WorldEnvironment")

@onready var compositor: Compositor = environment.compositor;
@onready var transition_effect: DataMoshEffect = compositor.compositor_effects[0]

var current_scene: Node3D;
var home_scene: Node3D;
var player: Player;
var player_home_spawn: Vector3

var tip: Label;
var reverb_effect: AudioEffectReverb;

func set_up_bus_effect():	
	reverb_effect = AudioEffectReverb.new()
	AudioServer.add_bus_effect(1, reverb_effect);

func get_reverb_effect():
	return reverb_effect;

func get_player():
	return player

func do_transition_effect():
	transition_effect.capture_screen()
	transition_effect.do_wipe = false
	await get_tree().process_frame # Render one frame.
	transition_effect.do_wipe = true;

func set_player(obj):
	player = obj
	tip = player.get_node("Control/Tip")

func set_vhs_intensity(wiggle: float, smear: float):
	vhs_effect.set_shader_parameter("wiggle", wiggle);
	vhs_effect.set_shader_parameter("smear", smear);

func display(text: String):
	tip.text = text

func get_time():
	return Time.get_ticks_msec() / 1000.0

func _ready():
	set_up_bus_effect()
