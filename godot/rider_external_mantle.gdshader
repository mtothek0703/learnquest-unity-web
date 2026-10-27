shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;
// Lightweight double-sided textile; UV edges, folds and animated wind are
// evaluated on the real four-weight skinned mesh, not separate rigid props.
uniform float side : hint_range(-1.0, 1.0) = 1.0;
varying vec2 cloth_uv;
void vertex() {
    cloth_uv = UV;
    float flutter = UV.y * UV.y;
    VERTEX.x += side * sin(TIME * 2.4 + UV.y * 8.0 + UV.x * 4.0) * 0.022 * flutter;
    VERTEX.z += sin(TIME * 3.1 + UV.y * 9.0 + UV.x * 6.0) * 0.030 * flutter;
}
void fragment() {
    float edge = 1.0 - smoothstep(0.01, 0.055, min(cloth_uv.x, 1.0 - cloth_uv.x));
    float hem = smoothstep(0.94, 0.995, cloth_uv.y);
    float ribs = pow(0.5 + 0.5 * cos(cloth_uv.x * 25.1327), 4.0);
    float fold = 0.5 + 0.5 * sin(cloth_uv.x * 16.0 + cloth_uv.y * 5.0);
    vec3 midnight = vec3(0.075, 0.10, 0.25);
    vec3 violet = vec3(0.38, 0.21, 0.65);
    vec3 cloth = mix(midnight, violet, 0.38 + 0.53 * fold);
    cloth += vec3(0.09, 0.11, 0.19) * ribs * 0.24;
    ALBEDO = cloth;
    METALLIC = 0.13;
    ROUGHNESS = 0.63;
    EMISSION = vec3(0.035, 0.52, 0.86) * max(edge * 0.7, hem * 0.55);
}
