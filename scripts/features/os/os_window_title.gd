@tool
class_name OSWindowTitle
extends RichTextLabel

# have to export so it remains saved
@export var display_text: String = "A very long title that will be truncated":
    set(value):
        display_text = value
        _original_text = value
        check_size()

var _original_text: String = ""
var _ellipsis_text: String = "..."

func _ready() -> void:
    text = display_text
    _original_text = display_text
    call_deferred("check_size")

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        check_size()

func check_size() -> void:
    var font: Font = get_theme_default_font()
    var font_size: int = get_theme_default_font_size()
    # TODO(calco): Figure out why has_theme_constant_override() is not working
    # if self.has_theme_constant_override("theme_override_colors/normal_font"):
    font = self.get("theme_override_fonts/normal_font")
    # if self.has_theme_constant_override("theme_override_font_sizes/normal_font_size"):
    font_size = self.get("theme_override_font_sizes/normal_font_size")
    if font == null:
        print("No font found, cannot check size.")
        return
    
    @warning_ignore("int_as_enum_without_cast")
    var text_width = font.get_string_size(_original_text, 0, -1, font_size).x
    @warning_ignore("int_as_enum_without_cast")
    var ellipsis_width = font.get_string_size(_ellipsis_text, 0, -1, font_size).x
    var available_width = size.x

    if available_width < text_width:
        var ellipsis_count = int((available_width - ellipsis_width) / (text_width / _original_text.length()))
        if ellipsis_count > 0:
            var ellipsis_text = _original_text.substr(0, ellipsis_count) + _ellipsis_text
            text = ellipsis_text
        else:
            text = _ellipsis_text
    else:
        text = _original_text

# Use _set to intercept text changes
func _set(property: StringName, value) -> bool:
    if property == "text":
        _original_text = value
        return false
    return false