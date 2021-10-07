shader_type canvas_item;

const float PI = 3.14159265359;
const float TWO_PI = 6.28318530718;
const float AA = 0.002;

uniform vec4 color: hint_color = vec4(vec3(0.0), 1.0);
uniform float value: hint_range(0, 1) = 0.0;
uniform bool fade_in = false;

uniform bool clockwise = true;
uniform float angle_offset: hint_range(0, 1) = 0.25;


float arc (vec2 st, vec2 center, float angle, float offset, bool c_wise) {
	float theta = atan(st.y - center.y, st.x - center.x) + PI;
	if (c_wise == false) theta = TWO_PI - theta;
    float over = angle + offset - 1.0;
    float p = smoothstep((angle + AA + offset) * TWO_PI, (angle + offset) * TWO_PI, theta);
    p -= smoothstep((offset + AA) * TWO_PI, (offset) * TWO_PI, theta);
    p += smoothstep((over + AA) * TWO_PI, over * TWO_PI, theta);
	
	if (fade_in) return 1.0 - p;
    return p;
} //aaa

void fragment() {
	COLOR = vec4(color.rgb, arc(UV, vec2(0.5), value, angle_offset, clockwise));
}