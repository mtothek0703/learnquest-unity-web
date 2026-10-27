shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;
// V124: a broad, bone-skinned split-wing flight mantle. Wind deformation is
// cosmetic, cheap in WebGL and tied to the existing rider pose (no physics).
uniform float side : hint_range(-1.0, 1.0) = 1.0;
uniform float wind_back_sign : hint_range(-1.0, 1.0) = 1.0;
uniform float steer_amount : hint_range(-1.0, 1.0) = 0.0;
uniform float boost_amount : hint_range(0.0, 1.0) = 0.0;
uniform float jump_amount : hint_range(0.0, 1.0) = 0.0;
varying vec2 cloth_uv;
void vertex() {
    cloth_uv = UV;
    float trailing = smoothstep(0.12, 1.0, UV.y);
    float flutter = trailing * trailing;
    float wave = sin(TIME * (2.2 + boost_amount * 2.4) + UV.y * 9.0 + UV.x * 5.5 + side * 0.7);
    VERTEX.x += side * wave * (0.012 + boost_amount * 0.027) * flutter;
    VERTEX.x += steer_amount * 0.050 * trailing;
    VERTEX.z += wind_back_sign * (0.018 + boost_amount * 0.045 + jump_amount * 0.020) * trailing;
    VERTEX.z += sin(TIME * 3.1 + UV.y * 9.0 + UV.x * 6.0) * 0.024 * flutter;
    VERTEX.y += sin(TIME * 2.6 + UV.y * 7.0) * 0.010 * flutter + jump_amount * 0.024 * trailing;
}
void fragment() {
    float edge = 1.0 - smoothstep(0.012, 0.055, min(cloth_uv.x, 1.0 - cloth_uv.x));
    float hem = smoothstep(0.94, 0.995, cloth_uv.y);
    float ribs = pow(0.5 + 0.5 * cos(cloth_uv.x * 25.1327), 4.0);
    float fold = 0.5 + 0.5 * sin(cloth_uv.x * 16.0 + cloth_uv.y * 5.0);
    vec3 midnight = vec3(0.12, 0.16, 0.34);
    vec3 violet = vec3(0.43, 0.23, 0.72);
    vec3 electric = vec3(0.10, 0.58, 0.88);
    vec3 cloth = mix(midnight, violet, 0.35 + 0.55 * fold);
    cloth = mix(cloth, electric, 0.13 + 0.16 * ribs);
    ALBEDO = cloth;
    METALLIC = 0.15;
    ROUGHNESS = 0.56;
    EMISSION = vec3(0.045, 0.57, 0.90) * max(edge * 0.86, hem * 0.74);
}
