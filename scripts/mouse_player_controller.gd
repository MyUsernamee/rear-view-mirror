extends Node3D
class_name MousePlayerController

@onready var camera: Camera3D = $%Camera
@onready var player: PlayerState = $%PlayerState

@export var max_turn_angle = 45;
