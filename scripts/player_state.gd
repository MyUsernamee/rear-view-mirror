extends Node3D
class_name PlayerState

@onready var inventory = $%Inventory;

func _ready():
	Game.set_player(self)
