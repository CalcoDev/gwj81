class_name OSWindowTitleBar
extends BoxContainer

var _window: OSWindow = null

var _mouse_over: bool = false
var _mouse_clicked: bool = false

func _ready() -> void:
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
            if _mouse_over and _window.inside_window_margin(_window.get_global_mouse_position()):
                _mouse_clicked = true
                get_viewport().set_input_as_handled()
        elif event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
            if _mouse_over:
                _mouse_clicked = false
                get_viewport().set_input_as_handled()
    elif event is InputEventMouseMotion:
        if _mouse_over and _mouse_clicked:
            _handle_mouse_motion(event)
            get_viewport().set_input_as_handled()

# TODO(calco): Fix dragging too fast and going outside window
func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
    var drag_delta = event.relative
    if drag_delta.length_squared() > 0:
        _window.position += drag_delta / 2.0

func _on_mouse_entered() -> void:
    _mouse_over = true

func _on_mouse_exited() -> void:
    _mouse_over = false
    _mouse_clicked = false
