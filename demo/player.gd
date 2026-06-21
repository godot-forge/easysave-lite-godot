extends Node2D
## A minimal "savable" node. Anything in the "easy_save" group that has these
## two methods gets persisted by EasySave with zero extra wiring.

func _save_state() -> Dictionary:
	return {"x": position.x, "y": position.y}


func _load_state(data: Dictionary) -> void:
	position = Vector2(data.get("x", 0.0), data.get("y", 0.0))
