extends Spatial

# A reference to the shader selector.
onready var shader_selector: OptionButton = get_node("ShaderSelector")
# A reference to the collection of shaders.
onready var shaders: Spatial = get_node("ScreenShaders")

# When the main scene is created we want to create the options and add them to
# the selector.
func _ready():
	# Add a default option for no shader.
	shader_selector.add_item("None")
	
	for shader in shaders.get_children():
		shader_selector.add_item(shader.get_name())

# When a shader is selected from the dropdown we want to show that shader and
# hide the rest.
#
# Arguments:
#
# `id` - The id of the item that was selected.
func _on_shader_selector_item_selected(id: int):
	# We need to create a normalized id because 0 is "None" in the dropdown but
	# it actually is the index of the first shader.
	var id_normalized: int = -1
	if id > 0: id_normalized = id - 1
	
	for shader_index in range(shaders.get_child_count()):
		var shader: ColorRect = shaders.get_child(shader_index)
		if id_normalized == shader_index: shader.show()
		else: shader.hide()
