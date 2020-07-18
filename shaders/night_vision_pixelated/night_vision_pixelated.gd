extends ColorRect

# The current frame that we are on.
var frame_number: int = 0

# Every frame we update the frame number and pass it to the shader param.
func _process(_delta):
	frame_number += 1
	self.get_material().set_shader_param("frame_number", frame_number)
