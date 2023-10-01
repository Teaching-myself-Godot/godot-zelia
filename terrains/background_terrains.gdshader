shader_type canvas_item;

void fragment() {
	vec4 in_c = texture(TEXTURE, UV);
	float out_b = max(in_c.g, max(in_c.r, in_c.b));
	COLOR = vec4(in_c.r * 0.8, in_c.g * 0.8, out_b, in_c.a * 0.6);
	
}
