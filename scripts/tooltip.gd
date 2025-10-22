extends Interactable
class_name Tooltip ## Simply shows a tooltip when hovered

@export var tip: String;

func _ready():
	on_hover.connect(_on_hover)
	stop_hover.connect(Game.display.bind(""))

func _on_hover():
	Game.display(tip)
