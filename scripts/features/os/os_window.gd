@tool
class_name OSWindow
extends Control

signal window_resized
signal window_title_changed

signal window_dragged

signal window_closed
signal window_minimized
signal window_maximized

@export var _title: OSWindowTitle = null
@export var _title_bar: OSWindowTitleBar = null

var window_margin_left: float = 3.0
var window_margin_top: float = 2.0
var window_margin_right: float = 3.0
var window_margin_bottom: float = 5.0

var _mouse_over: bool = false
var _mouse_clicked: bool = false

func _ready() -> void:
    if Engine.is_editor_hint():
        return

    if _title:
        _title.title_changed.connect(_on_title_changed)
    if _title_bar:
        _title_bar._window = self
    
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
            if _mouse_over and inside_margin(get_global_mouse_position()):
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

func _process(_delta: float) -> void:
    var mouse_pos := get_global_mouse_position()
    if _mouse_over and inside_margin(mouse_pos):
        OSManager.cursors.main_cursor = _get_cursor_resize_shape(mouse_pos)
    elif OSManager.cursors.main_cursor != Input.CURSOR_ARROW:
        OSManager.cursors.main_cursor = Input.CURSOR_ARROW

func set_title(title: String) -> void:
    if _title:
        _title.display_text = title

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        _on_window_resized()

func _on_window_resized() -> void:
    window_resized.emit()

func _on_title_changed() -> void:
    window_title_changed.emit()

func _is_inside_with_margin(pos: Vector2, ml: float, mt: float, mr: float, mb: float) -> bool:
    var rect = Rect2(Vector2(ml, mt), size - Vector2(mr + ml, mb + mt))
    rect.position += global_position
    return rect.has_point(pos)

func _get_cursor_resize_shape(pos: Vector2) -> Input.CursorShape:
    pos -= global_position
    if pos.x < window_margin_left:
        if pos.y < window_margin_top:
            return Input.CURSOR_FDIAGSIZE
        elif pos.y > size.y - window_margin_bottom:
            return Input.CURSOR_BDIAGSIZE
        else:
            return Input.CURSOR_HSIZE
    elif pos.x > size.x - window_margin_right:
        if pos.y < window_margin_top:
            return Input.CURSOR_BDIAGSIZE
        elif pos.y > size.y - window_margin_bottom:
            return Input.CURSOR_FDIAGSIZE
        else:
            return Input.CURSOR_HSIZE
    elif pos.y < window_margin_top:
        return Input.CURSOR_VSIZE
    elif pos.y > size.y - window_margin_bottom:
        return Input.CURSOR_VSIZE
    return Input.CURSOR_ARROW

func inside_window_margin(pos: Vector2) -> bool:
    return _is_inside_with_margin(pos, window_margin_left, window_margin_top, window_margin_right, window_margin_bottom)

func inside_window(pos: Vector2) -> bool:
    var rect = Rect2(Vector2(0, 0), size)
    rect.position += global_position
    return rect.has_point(pos)

func inside_margin(pos: Vector2) -> bool:
    return inside_window(pos) and not inside_window_margin(pos)

func _on_mouse_entered() -> void:
    _mouse_over = true

func _on_mouse_exited() -> void:
    _mouse_clicked = false
    _mouse_over = false

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
    var resize_delta = event.relative
    if resize_delta.length_squared() > 0:
        # Resize the window using the delta
        size += resize_delta / 2.0
