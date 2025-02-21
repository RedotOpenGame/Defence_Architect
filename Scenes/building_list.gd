extends ItemList

signal item_hovered(index: int)

var hovered_item := -1

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_pos := get_local_mouse_position()
		var index = get_item_at_position(mouse_pos, true)
		if hovered_item != index:
			if index != -1:
				item_hovered.emit(index)
			hovered_item = index

func _on_mouse_exited() -> void:
	hovered_item = -1
