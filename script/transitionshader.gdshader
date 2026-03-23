shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.0) = 1.0;
uniform vec2 center = vec2(0.5, 0.5);

void fragment() {
    vec2 uv = SCREEN_UV;

    // Corrected for screen size: scale to same ratio
    vec2 offset = uv - center;
    offset.x *= SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;

    float dist = length(offset);

    if(dist < radius){
        discard; // transparent circle
    } else { 
        COLOR = vec4(0.0, 0.0, 0.0, 1.0); // black outside
    }
}