shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;
// Sculpted four-weight source-body yoke: metallic shoulders and fabric collar.
// Normalized rest-pose coordinates keep the design aligned with the CC0 mesh.
uniform float rest_bottom = 0.0;
uniform float rest_height = 2.0;
uniform float rest_center_x = 0.0;
uniform float rest_width = 2.0;
varying vec3 rest_point;
void vertex() {
    rest_point = VERTEX;
}
void fragment() {
    float y = (rest_point.y - rest_bottom) / max(rest_height, 0.01);
    float x = abs(rest_point.x - rest_center_x) / max(rest_width, 0.01);
    float shoulder = smoothstep(0.075, 0.19, x);
    float central = 1.0 - smoothstep(0.07, 0.20, x);
    float collar = exp(-pow((y - 0.765) * 82.0, 2.0));
    float piping = exp(-pow((x - 0.16) * 60.0, 2.0));
    float seam = exp(-pow((y - 0.642) * 78.0, 2.0));
    vec3 graphite = vec3(0.055, 0.09, 0.19);
    vec3 titanium = vec3(0.19, 0.24, 0.42);
    vec3 violet = vec3(0.22, 0.12, 0.45);
    vec3 surface_color = mix(graphite, titanium, shoulder * 0.85);
    surface_color = mix(surface_color, violet, central * 0.42);
    ALBEDO = surface_color;
    METALLIC = mix(0.23, 0.65, shoulder);
    ROUGHNESS = mix(0.56, 0.32, shoulder);
    EMISSION = vec3(0.02, 0.48, 0.81) * max(collar * 0.36, max(piping * 0.52, seam * 0.20));
}
