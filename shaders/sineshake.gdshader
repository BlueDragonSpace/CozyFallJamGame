shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;

uniform float frequency = 10.0;
uniform float amplitude = 0.01;

void fragment() {
    // Calculate UV coordinates
	vec2 uv = SCREEN_UV;
    // Offset the UV coordinates based on a sine wave
    uv.x += sin(SCREEN_UV.y * frequency + TIME) * amplitude; // Adjust the frequency and amplitude as needed
    uv.y += sin(SCREEN_UV.x * frequency + TIME) * amplitude;

    // Sample the texture using the modified UV coordinates
    COLOR = texture(screen_texture, uv);
}