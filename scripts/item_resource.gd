extends Resource
class_name ItemResource

@export var id: String;
@export var name: String;
@export var description: String;
@export var view_model: PackedScene;

func _init() -> void:

    id = ""
    name = ""
    description = ""
    view_model = null