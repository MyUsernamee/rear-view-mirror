@tool
extends CompositorEffect
class_name DataMoshEffect

# TODO: Clean this up

const GROUP_SIZE = 8;

var shader_source: RDShaderFile = load("res://shaders/datamosh.glsl")
var copy_shader_source: RDShaderFile = load("res://shaders/copy_frame.glsl")

var rd: RenderingDevice;
var shader: RID;
var copy_shader: RID;
var pipeline: RID;
var copy_pipeline: RID;

var frozen_image: RID;
var capture_screen_storage_buffer: RID;

var capturing_screen = false;
var do_wipe = true;

var last_capture_time: float;

func capture_screen():
	if capturing_screen:
		return

	capturing_screen = true;
	last_capture_time = Time.get_ticks_msec() / 1000.0;

func get_time_since_last_capture():
	return Time.get_ticks_msec() / 1000.0 - last_capture_time;

func compile_shader():
	if not rd:
		return false;

	if shader.is_valid():
		rd.free_rid(shader)
		shader = RID()
		copy_shader = RID()
		pipeline = RID()

	shader = rd.shader_create_from_spirv(shader_source.get_spirv())
	copy_shader = rd.shader_create_from_spirv(copy_shader_source.get_spirv())

	pipeline = rd.compute_pipeline_create(shader)
	copy_pipeline = rd.compute_pipeline_create(copy_shader)
	return pipeline.is_valid()

func check_create_image_buffer(size):
	if not frozen_image.is_valid():
			var tformat = RDTextureFormat.new()
			tformat.format = RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT
			tformat.width = size.x
			tformat.height = size.y
			tformat.usage_bits = RenderingDevice.TEXTURE_USAGE_CAN_COPY_TO_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice.TEXTURE_USAGE_STORAGE_BIT
			var tview = RDTextureView.new()
			frozen_image = rd.texture_create(tformat, tview, []);


func _init() -> void: 
	effect_callback_type = EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	rd = RenderingServer.get_rendering_device()
	needs_motion_vectors = true;
	var a = PackedByteArray()
	a.append(capturing_screen);
	capture_screen_storage_buffer = rd.uniform_buffer_create(a.size(), a)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if shader.is_valid():
			rd.free_rid(shader);
			rd.free_rid(copy_shader);

func _render_callback(effect_callback_type: int, render_data: RenderData) -> void:

	if rd and effect_callback_type == EFFECT_CALLBACK_TYPE_POST_TRANSPARENT and compile_shader():
		var render_scene_buffers : RenderSceneBuffersRD = render_data.get_render_scene_buffers()
		if render_scene_buffers:
			var size = render_scene_buffers.get_internal_size()
			if size.x == 0 and size.y == 0:
				return

			var x_groups = (size.x - 1) / GROUP_SIZE + 1;
			var y_groups = (size.y - 1) / GROUP_SIZE + 1;
			var z_groups = 1;

			check_create_image_buffer(size)

			var push_constant = PackedFloat32Array();
			push_constant.push_back(size.x);
			push_constant.push_back(size.y);
			push_constant.push_back(get_time_since_last_capture())
			push_constant.push_back(0.0);
			
			var view_count = render_scene_buffers.get_view_count()
			for view in range(view_count):
				var input_image: RID = render_scene_buffers.get_color_layer(view)
				var motion_vectors = render_scene_buffers.get_velocity_layer(view);

				# Create a uniform set.
				# This will be cached; the cache will be cleared if our viewport's configuration is changed.
				var uniform: RDUniform = RDUniform.new()
				uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
				uniform.binding = 0
				uniform.add_id(input_image)

				var og_image_uniform = RDUniform.new()
				og_image_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
				og_image_uniform.binding = 1
				og_image_uniform.add_id(frozen_image);


				var motion_vector_uniform = RDUniform.new()
				motion_vector_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE;
				motion_vector_uniform.binding = 2
				motion_vector_uniform.add_id(motion_vectors);

				var uniform_set = UniformSetCacheRD.get_cache(shader, 0, [ uniform, motion_vector_uniform, og_image_uniform ])
				var copy_uniform_set = UniformSetCacheRD.get_cache(copy_shader, 0, [uniform, og_image_uniform ])

				# Run our compute shader.
				var compute_list:= rd.compute_list_begin()
				if capturing_screen :
					capturing_screen = false;
					rd.compute_list_bind_compute_pipeline(compute_list, copy_pipeline,)
					rd.compute_list_bind_uniform_set(compute_list, copy_uniform_set, 0)
					rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), push_constant.size() * 4)
					rd.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups);

				if do_wipe:
					rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
					rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
					rd.compute_list_set_push_constant(compute_list, push_constant.to_byte_array(), push_constant.size() * 4)
					rd.compute_list_dispatch(compute_list, x_groups, y_groups, z_groups)

				rd.compute_list_end()


