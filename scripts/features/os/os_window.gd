@tool
class_name OSWindow
extends Control

signal window_resized

@export var _title: OSWindowTitle = null

func set_title(title: String) -> void:
    if _title:
        _title.display_text = title

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        _on_window_resized()

func _on_window_resized() -> void:
    window_resized.emit()