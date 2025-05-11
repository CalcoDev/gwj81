@tool
class_name OSWindow
extends Control

#region Signals

signal window_resized
signal window_title_changed

# TODO(calco): Add signals for moved, dragged, resized etc

signal window_closed
signal window_minimized
signal window_maximized

#endregion

#region Properties

@export var _title: OSWindowTitle = null
@export var _title_bar: OSWindowTitleBar = null

var window_margin_left: float = 3.0
var window_margin_top: float = 2.0
var window_margin_right: float = 3.0
var window_margin_bottom: float = 5.0

#endregion

#region Variables

var _mouse_over: bool = false
var _mouse_clicked: bool = false
var _mouse_clicked_pos: Vector2 = Vector2.ZERO
var _resize_begin_window_rect: Rect2 = Rect2(0, 0, 0, 0)
var _resize_begin_cursor: Input.CursorShape = Input.CURSOR_ARROW

var _real_size: Vector2 = Vector2.ZERO
var _real_position: Vector2 = Vector2.ZERO

#endregion

#region Node Lifecycle

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        _on_window_resized()

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
    if Engine.is_editor_hint():
        return

    if event is InputEventMouseButton:
        if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
            if _mouse_over and inside_margin(get_global_mouse_position()):
                _mouse_clicked = true
                
                _mouse_clicked_pos = get_global_mouse_position()
                _resize_begin_window_rect = get_global_rect()
                _resize_begin_cursor = _get_cursor_resize_shape(get_global_mouse_position())

                # TODO(calco): Move this out of here and into a setter
                position = position.round()
                size = size.round()
                _real_position = position
                _real_size = size

                get_viewport().set_input_as_handled()
        elif event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
            _mouse_clicked = false
            if _mouse_over:
                get_viewport().set_input_as_handled()
    elif event is InputEventMouseMotion:
        if _mouse_clicked:
            _handle_mouse_motion(event)
            get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
    if Engine.is_editor_hint():
        return

    if not _mouse_clicked:
        var mouse_pos := get_global_mouse_position()
        if _mouse_over and inside_margin(mouse_pos):
            OSManager.cursors.main_cursor = _get_cursor_resize_shape(mouse_pos)
        elif OSManager.cursors.main_cursor != Input.CURSOR_ARROW:
            OSManager.cursors.main_cursor = Input.CURSOR_ARROW

#endregion

#region API

# TODO(calco): Implement this
func close() -> void:
    pass

func minimize() -> void:
    pass

func maximize() -> void:
    pass

func set_title(title: String) -> void:
    if _title:
        _title.display_text = title

## Returns whether the position is inside the window, taking margins into account.
func is_inside_window(pos: Vector2) -> bool:
    return _is_inside_with_margin(pos, window_margin_left, window_margin_top, window_margin_right, window_margin_bottom)

## Returns whether the position is inside the window, WITHOUT taking margins into account.
func is_inside_physical_window(pos: Vector2) -> bool:
    var rect = Rect2(Vector2(0, 0), size)
    rect.position += global_position
    return rect.has_point(pos)

## Returns whether the position is inside the margins of the window.
func inside_margin(pos: Vector2) -> bool:
    return is_inside_physical_window(pos) and not is_inside_window(pos)

#endregion

#region Callbacks

func _on_window_resized() -> void:
    window_resized.emit()

func _on_title_changed() -> void:
    window_title_changed.emit()

func _on_mouse_entered() -> void:
    _mouse_over = true

func _on_mouse_exited() -> void:
    _mouse_over = false

#endregion

#region Resizing Helpers

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
    var resize_delta = event.relative
    if resize_delta.length_squared() > 0:
        var movement_update := _get_cursor_resize_clamped(_resize_begin_cursor, _mouse_clicked_pos, get_global_mouse_position(), resize_delta) / 2.0
        var size_update = Vector2(movement_update.x, movement_update.y)
        var position_update = Vector2(movement_update.z, movement_update.w)
        _real_size += size_update
        _real_position += position_update
        size = _real_size.round()
        position = _real_position.round()

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

## First 2 components are the Size update, second 2 are the Position update
func _get_cursor_resize_clamped(cursor: Input.CursorShape, start_pos: Vector2, curr_pos: Vector2, delta: Vector2) -> Vector4:
    if cursor == Input.CURSOR_HSIZE:
        return _get_cursor_resize_clamped_horizontal_axis_func1(start_pos, curr_pos, delta)
    elif cursor == Input.CURSOR_VSIZE:
        return _get_cursor_resize_clamped_vertical_axis_func2(start_pos, curr_pos, delta)
    elif cursor == Input.CURSOR_FDIAGSIZE or cursor == Input.CURSOR_BDIAGSIZE:
        var ret := _get_cursor_resize_clamped_horizontal_axis_func1(start_pos, curr_pos, delta)
        ret += _get_cursor_resize_clamped_vertical_axis_func2(start_pos, curr_pos, delta)
        return ret
    return Vector4.ZERO

func _get_cursor_resize_clamped_horizontal_axis_func1(start_pos: Vector2, curr_pos: Vector2, delta: Vector2) -> Vector4:
    var ret := Vector4(delta.x, 0.0, 0.0, 0.0)
    if start_pos.x > _resize_begin_window_rect.get_center().x:
        if start_pos.x < global_position.x:
            ret.x = 0
    else:
        ret.x *= -1
        # print(ret.x)
        # print("start_pos: ", start_pos.x, " glob: ", global_position.x + size.x)
        if curr_pos.x > global_position.x + size.x - custom_minimum_size.x or ret.x < 0 and size.x == custom_minimum_size.x:
            ret.x = 0
        ret.z = -ret.x
    return ret;

func _get_cursor_resize_clamped_vertical_axis_func2(start_pos: Vector2, curr_pos: Vector2, delta: Vector2) -> Vector4:
    var ret := Vector4(0.0, delta.y, 0.0, 0.0)
    if start_pos.y > _resize_begin_window_rect.get_center().y:
        if start_pos.y < global_position.y:
            ret.y = 0
    else:
        ret.y *= -1
        if curr_pos.y > global_position.y + size.y - custom_minimum_size.y or ret.y < 0 and size.y == custom_minimum_size.y:
            ret.y = 0
        ret.w = -ret.y
    return ret;

#endregion

#region Margin Helpers

func _is_inside_with_margin(pos: Vector2, ml: float, mt: float, mr: float, mb: float) -> bool:
    var rect = Rect2(Vector2(ml, mt), size - Vector2(mr + ml, mb + mt))
    rect.position += global_position
    return rect.has_point(pos)

#endregion