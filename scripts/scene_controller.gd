extends AnimationPlayer

func _ready():
	animation_finished.connect(pause)
