#pragma header

#define p 3.1415
#define hP 1.57075

const vec2 res = vec2(1324., 754.);
const float Zoom = 300;
vec2 uv = openfl_TextureCoordv;
vec2 iResolution = openfl_TextureSize;
void main() {
	vec2 uv = openfl_TextureCoordv;
	vec2 fragCoord = (uv * res);
	
	float CurrentSinStep = ((fragCoord.x - (res.x / 2.)) / (res.x / p)) + hP;
	float CurrentHeight = (max(1., res.y + sin(CurrentSinStep) * Zoom - Zoom));
	float yThing = (res.y - CurrentHeight);
	float newY = uv.y - ((uv.y - 0.5) * (yThing / res.y));
	
	gl_FragColor = flixel_texture2D(bitmap, vec2(uv.x, newY));
}
