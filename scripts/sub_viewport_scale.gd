extends SubViewport

func _ready() -> void:
	get_parent().get_viewport().size_changed.connect(_size_changed)
	size = get_parent().get_viewport().size
	print(size)

func _size_changed():
	size = Vector2i.ONE * get_parent().get_viewport().size
