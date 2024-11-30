shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture;
uniform float radius;
uniform float size;
uniform float force;
uniform float thickness;

void fragment() {
	// COLOR = texture(screen_texture, SCREEN_UV);
	// COLOR.a = texture(TEXTURE, UV).a;
	
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(UV, vec2(0.5, 0.5));
	float mask = (1.0 - smoothstep(size, size-thickness, length(UV - center))) *
        smoothstep(size, size-thickness, length(UV - center));
	vec2 disp = normalize(UV - center) * force * mask;
    COLOR = texture(screen_texture, SCREEN_UV - disp);
	
	if (dist >= radius) {
		COLOR.a = 0.0;
	}
}