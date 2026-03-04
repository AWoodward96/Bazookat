shader_type canvas_item;

uniform bool obscure = true;
uniform float cutoff = 0;
uniform vec4 fade_color : source_color = vec4(0, 0, 0, 1);

void fragment() {
	vec4 c = COLOR;
	if (obscure)
	{
		if (c.b < cutoff)
		{
			COLOR = fade_color;
		} else
		{
			COLOR = vec4(0, 0, 0, 0);
		}
	} else
	{
		if (c.b < cutoff)
		{
			COLOR = vec4(0, 0, 0, 0);
		} else
		{
			COLOR = fade_color;
		}
	}

}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
