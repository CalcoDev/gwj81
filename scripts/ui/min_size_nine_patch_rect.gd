@tool
class_name MinSizeNinePatchRect
extends NinePatchRect

# Override the texture property to update the minimum size when changed
# @export var texture: Texture2D:
# 	get:
# 		return super.get("texture")
# 	set(value):
# 		super.set("texture", value)
# 		_update_minimum_size()

# Cant call super.set() as it would just call this endlessly :skull:
func _set(property: StringName, value) -> bool:
    # print("MinSizeNinePatchRect::_set() property: ", property, " value: ", value)
    if property == "texture":
        texture = value
        _update_minimum_size()
        return true
    if "patch_margin" in property:
        if property == "patch_margin_left":
            patch_margin_left = value
        elif property == "patch_margin_top":
            patch_margin_top = value
        elif property == "patch_margin_right":
            patch_margin_right = value
        elif property == "patch_margin_bottom":
            patch_margin_bottom = value
        _update_minimum_size()
        return true
    return false

# func _notification(what: int) -> void:
#     match what:
#         NOTIFICATION_RESIZED, NOTIFICATION_ENTER_TREE:
#             _update_minimum_size()
        # Listen for property changes - this is called when a property changes

func _update_minimum_size() -> void:
    if texture:
        custom_minimum_size = texture.get_size()
        custom_minimum_size.x -= patch_margin_left + patch_margin_right
        custom_minimum_size.y -= patch_margin_top + patch_margin_bottom