shader_type canvas_item;

uniform vec4 minColor;
uniform vec4 maxColor;
uniform float speedMult = 2;

uniform float width;
uniform float height;
uniform float distFromEdge = 0.3;

void vertex() {
	// Called for every vertex the material is visible on.
}

float inverseLerp(float a, float b, float val)
{
	return (val - a) / (b - a);
}

float lerp(float a, float b, float t)
{
	float fakeT = sqrt(t);
	float boundedT = max(fakeT, 0);
	boundedT = min(boundedT, 1);
	return a + ((b - a) * boundedT);
}

vec4 lerp(vec4 a, vec4 b, float t)
{
	float boundedT = max(t, 0);
	boundedT = min(t, 1);
	return vec4(lerp(a.x, b.x, t), lerp(a.y, b.y, t), lerp(a.z, b.z, t), lerp(a.a, b.a, t));
}

void fragment() {
	float t = inverseLerp(-1, 1, sin(TIME * speedMult));
	vec4 color = lerp(minColor, maxColor, t);
	
	COLOR = color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
