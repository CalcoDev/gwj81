class_name OSCursors
extends Node

var _cursors: Dictionary[Input.CursorShape, Resource] = {
    Input.CURSOR_ARROW: _load_cursor("arrow-export.png"),
    Input.CURSOR_POINTING_HAND: _load_cursor("pointing_hand-export.png"),
    Input.CURSOR_WAIT: _load_cursor("wait-export.png"),
    Input.CURSOR_BUSY: _load_cursor("wait-export.png"),
    Input.CURSOR_FORBIDDEN: _load_cursor("forbidden-export.png"),
    Input.CURSOR_VSIZE: _load_cursor("vsize-export.png"),
    Input.CURSOR_HSIZE: _load_cursor("hsize-export.png"),
    Input.CURSOR_BDIAGSIZE: _load_cursor("bdiagsize-export.png"),
    Input.CURSOR_FDIAGSIZE: _load_cursor("fdiagsize-export.png"),
    Input.CURSOR_HELP: _load_cursor("help-export.png"),
}

var main_cursor: Input.CursorShape = Input.CURSOR_ARROW:
    set(value):
        if _cursors.has(value):
            Input.set_custom_mouse_cursor(_cursors[value], Input.CURSOR_ARROW, Vector2(0, 0))
            main_cursor = value
        else:
            print("Cursor not found: ", value)

func _ready() -> void:
    enable_cursors()

func _load_cursor(path: String) -> Resource:
    var cursor = load("res://assets/art/os/cursor/" + path)
    if cursor is Texture:
        return cursor
    else:
        print("Error loading cursor: ", path)
        return null

func enable_cursors() -> void:
    main_cursor = Input.CURSOR_ARROW
    for cursor in _cursors.keys():
        Input.set_custom_mouse_cursor(_cursors[cursor], cursor, Vector2(0, 0))

func disable_cursors() -> void:
    main_cursor = Input.CURSOR_ARROW
    for cursor in _cursors.keys():
        Input.set_custom_mouse_cursor(null, cursor, Vector2(0, 0))