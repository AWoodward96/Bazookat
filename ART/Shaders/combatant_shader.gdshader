shader_type canvas_item;

uniform float use_color_override = 0;
uniform vec4 color_override : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform bool perform_color_swap = false;
uniform vec4 color_to_swap : source_color;
uniform vec4 color_to_swap_to : source_color;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform int type : hint_enum("Disable", "Round", "Square") = 2;
uniform float thickness = 1.0;

const vec2[8] DIRECTIONS = {
	vec2(1.0, 0.0),
	vec2(0.0, 1.0),
	vec2(-1.0, 0.0),
	vec2(0.0, -1.0),
	vec2(1.0, 1.0),
	vec2(-1.0, 1.0),
	vec2(-1.0, -1.0),
	vec2(1.0, -1.0)
};

float gtz(float input) { return max(0, sign(input)); }
// returns 1 if input > 0, else 0

float check(sampler2D tex, vec2 from, vec2 size) {
	float result = 0.0;
	for (int i = 0; i < 4 * type; i++) {
		result += texture(tex, from + DIRECTIONS[i] * size * thickness).a;
	}
	return gtz(result);
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec4 newColor = color;
	if (perform_color_swap)
	{
		if (color == color_to_swap)
		{
			newColor = color_to_swap_to;
		}	
	}
	
	
	if (use_color_override > 0.0)
	{
		newColor = mix(newColor, color_override, use_color_override);
		newColor.a = color.a * color_override.a;
	}
	
	newColor = mix(newColor, outline_color, check(TEXTURE, UV, TEXTURE_PIXEL_SIZE) * (1.0 - gtz(COLOR.a)) );
	
	COLOR = newColor;
}
