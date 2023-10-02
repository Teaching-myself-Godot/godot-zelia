shader_type canvas_item;

uniform float fade  = 0.0;
uniform float scatter = 0.0;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}


void fragment() {
	vec4 in_c = texture(TEXTURE, UV);
	if (random(UV) > scatter) {
		COLOR = vec4(in_c.r, in_c.g, in_c.b, in_c.a * (1.0 - fade));
	} else {
		COLOR = vec4(0,0,0,0);
	}
	
}
