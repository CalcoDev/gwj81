class_name OSWindowTitleBar
extends BoxContainer

#region Properties

@export var _maximize_button: TextureButton = null
@export var _minimize_button: TextureButton = null
@export var _close_button: TextureButton = null

var _window: OSWindow = null

#endregion

#region Variables

var _mouse_over: bool = false
var _mouse_clicked: bool = false
var _pos_offset: Vector2 = Vector2.ZERO

#endregion

#region Node Lifecycle

func _ready() -> void:
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)

    _maximize_button.pressed.connect(_on_maximize_button_pressed)
    _minimize_button.pressed.connect(_on_minimize_button_pressed)
    _close_button.pressed.connect(_on_close_button_pressed)

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
            if _mouse_over and _window.is_inside_window(_window.get_global_mouse_position()):
                _mouse_clicked = true
                _pos_offset = _window.get_global_mouse_position() - _window.position
                get_viewport().set_input_as_handled()
        elif event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
            if _mouse_over:
                _mouse_clicked = false
                # NOTE(calco): This is needed to make sure to propagate this to window!
                # get_viewport().set_input_as_handled()
    elif event is InputEventMouseMotion:
        if _mouse_clicked:
            _handle_mouse_motion(event)
            get_viewport().set_input_as_handled()

#endregion

#region Callbacks

func _on_mouse_entered() -> void:
    _mouse_over = true

func _on_mouse_exited() -> void:
    _mouse_over = false
    # _mouse_clicked = false

func _on_maximize_button_pressed() -> void:
    _window.maximize()

func _on_minimize_button_pressed() -> void:
    _window.minimize()

func _on_close_button_pressed() -> void:
    _window.close()

#endregion

#region Helpers

# TODO(calco): Fix dragging too fast and going outside window
func _handle_mouse_motion(_event: InputEventMouseMotion) -> void:
    var new_pos = _window.get_global_mouse_position() - _pos_offset
    _window.position = new_pos

#endregion