# Phase 1 checkpoint — "A picture and a caption".
#
# At this point the script does almost nothing, and that's the point:
# Phase 1 is about building the scene tree out of containers and proving
# that a script + a signal connection work. The rack, tiles, and rules
# arrive in Phases 2–3.
extends Control


func _ready() -> void:
	print("Level scene is ready!")


# Connected in the editor: SubmitButton → Node dock → Signals tab →
# "pressed()" → this node. (Godot generated this method name for us.)
func _on_submit_button_pressed() -> void:
	print("submitted!")
