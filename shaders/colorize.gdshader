shader_type canvas_item;

uniform int bit_size = 2;
// If you intend to read from mipmaps with `textureLod()` LOD values greater than `0.0`,
// use `filter_nearest_mipmap` instead. This shader doesn't require it.
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {

	vec3 new_color = texture(screen_texture, SCREEN_UV).xyz;

	COLOR = vec4(floor(new_color * float(1 << bit_size)) / float(1 << bit_size), 1.0);
}