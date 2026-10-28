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
    // Dark structural upper surface with a broad illuminated cyan spar.
    // The former all-purple cloth read as a skirt and hid the character.
    float edge = 1.0 - smoothstep(0.012, 0.055, min(cloth_uv.x, 1.0 - cloth_uv.x));
    float tip = smoothstep(0.84, 1.0, cloth_uv.y);
    float foil_ridge = exp(-pow((cloth_uv.x - 0.58) * 12.0, 2.0));
    float sweep_panel = smoothstep(0.12, 0.28, cloth_uv.x)
        * (1.0 - smoothstep(0.78, 0.94, cloth_uv.x));
    float fold = 0.5 + 0.5 * sin(cloth_uv.x * 8.0 + cloth_uv.y * 3.0);
    vec3 midnight = vec3(0.055, 0.085, 0.21);
    vec3 cobalt = vec3(0.14, 0.27, 0.56);
    vec3 violet = vec3(0.33, 0.17, 0.57);
    vec3 electric = vec3(0.07, 0.66, 0.94);
    vec3 shell = mix(midnight, cobalt, sweep_panel * 0.80);
    shell = mix(shell, violet, 0.08 + 0.15 * fold);
    shell = mix(shell, electric, foil_ridge * 0.36 * (1.0 - tip * 0.5));
    ALBEDO = shell;
    METALLIC = 0.32;
    ROUGHNESS = 0.38 + 0.12 * fold;
    EMISSION = electric * (edge * 0.57 + foil_ridge * 0.31 + tip * 0.18);
    float silhouette_rim = pow(1.0 - abs(dot(normalize(NORMAL), normalize(VIEW))), 2.6);
    ALBEDO = min(ALBEDO * (1.0 + silhouette_rim * 0.16), vec3(1.0));
    EMISSION += vec3(0.11, 0.33, 0.60) * silhouette_rim * 0.17;
}
