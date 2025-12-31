shader_type canvas_item;
render_mode unshaded;

uniform float screen_width;
uniform float screen_height;
uniform float circle_size : hint_range(0.0, 1.0);
uniform float feather : hint_range(0.0, 0.2);
uniform vec2 circle_position;

void fragment() {
    vec2 screen_uv = UV * vec2(screen_width, screen_height);
    vec2 circle_center = circle_position * vec2(screen_width, screen_height);

    float dist = distance(screen_uv, circle_center);
    float max_size = length(vec2(screen_width, screen_height));
    float radius = circle_size * max_size * 0.5;

    float alpha = smoothstep(
        radius - feather * max_size,
        radius + feather * max_size,
        dist
    );

    COLOR = vec4(vec3(0.0), alpha);
}