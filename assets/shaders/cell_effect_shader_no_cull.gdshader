shader_type spatial;

render_mode unshaded, cull_back;

uniform vec3 Color: source_color;
uniform vec3 glow_color: source_color;
uniform float dist;
uniform float speed;
uniform float glow_intensity;
uniform float glow_amount;
uniform float posMult;
uniform sampler2D noise: repeat_enable;

void vertex()
{
	//float randx = fract(sin(dot(vec2(4.9298 * TIME, 9.1514), vec2(2.9898, 4.1414 * TIME))) * 4758.5453) * TIME;
	//float randy = fract(sin(dot(vec2(66.9298, 14.1514 * TIME), vec2(12.9898 * TIME, 4.1414))) * 4758.5453);
	//vec4 pos = texture(noise, vec2(randx * speed, randy * speed)) - vec4(0.5);
	vec4 pos = texture(noise, vec2(VERTEX.x + TIME * speed,VERTEX.y + TIME * speed)) - vec4(0.5);
	VERTEX += (pos.xyz * posMult) * NORMAL;
}

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

vec3 fresnel_glow(float amount, float intensity, vec3 color, vec3 normal, vec3 view)
{
	return pow((1.0 - dot(normalize(normal), normalize(view))), amount) * color * intensity;
}

void fragment() {
	vec3 glow_fresnel = fresnel_glow(glow_amount, glow_intensity, glow_color, NORMAL, VIEW);

	float rimLevel = texture(noise, vec2(NORMAL.x + (TIME * speed),NORMAL.y)).r;

	ALBEDO = Color + glow_fresnel * rimLevel;
	float fresnel = fresnel(dist, NORMAL, VIEW);
	RIM = rimLevel;
	ALPHA = fresnel;
}
