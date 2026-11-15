extends Node2D

func _process(delta: float) -> void:
	if get_children().is_empty():
		pass # go to next level
