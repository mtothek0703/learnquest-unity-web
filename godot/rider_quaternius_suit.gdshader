shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;
// Shared action lighting on the original GPU-skinned hero; no extra meshes.
uniform float action_boost : hint_range(0.0, 1.0) = 0.0;
uniform float action_carve : hint_range(-1.0, 1.0) = 0.0;
uniform float action_jump : hint_range(0.0, 1.0) = 0.0;


// V124 DRAFT: fit the actual imported CC0 body's original rest-space bounds.
// Previous absolute-y thresholds made the underlying 65-bone suit depend on
// one exporter scale, leaving dark discontinuities between weighted garments.
// This remains a single PBR draw pass on the genuine four-weight body mesh.
uniform float rest_bottom = 0.0;
uniform float rest_height = 3.0;
uniform float rest_center_x = 0.0;
uniform float rest_width = 1.0;
varying vec3 rest_point;

void vertex() {
    rest_point = VERTEX;
}
void fragment() {
    float y = clamp((rest_point.y - rest_bottom) / max(rest_height, 0.001), 0.0, 1.0);
    float x = abs(rest_point.x - rest_center_x) / max(rest_width, 0.001);
    float torso = smoothstep(0.39, 0.47, y) * (1.0 - smoothstep(0.76, 0.83, y));
    float shoulder = smoothstep(0.63, 0.72, y) * smoothstep(0.11, 0.27, x);
    float boots = 1.0 - smoothstep(0.13, 0.23, y);
    float thigh = smoothstep(0.22, 0.33, y) * (1.0 - smoothstep(0.44, 0.53, y));
    float center = 1.0 - smoothstep(0.05, 0.18, x);
    float outer = smoothstep(0.13, 0.31, x);
    vec3 midnight = vec3(0.085, 0.12, 0.27);
    vec3 cobalt = vec3(0.19, 0.44, 0.86);
    vec3 violet = vec3(0.47, 0.27, 0.77);
    vec3 magenta = vec3(0.88, 0.25, 0.55);
    vec3 titanium = vec3(0.32, 0.45, 0.64);
    vec3 cloth = mix(midnight, cobalt, 0.28 + torso * 0.52 + thigh * 0.30);
    cloth = mix(cloth, violet, torso * center * 0.56 + thigh * outer * 0.28);
    cloth = mix(cloth, magenta, shoulder * 0.60);
    cloth = mix(cloth, titanium, boots * 0.70);
    // Real source hands/neck remain visible; the weighted jacket, sleeves and
    // lower suit retain their own modeled surfaces and matching palette.
    float face = smoothstep(0.81, 0.88, y);
    float hands = smoothstep(0.32, 0.43, x) *
        smoothstep(0.43, 0.51, y) * (1.0 - smoothstep(0.74, 0.82, y));
    float uncovered = clamp(max(face, hands), 0.0, 1.0);
    vec3 skin = vec3(0.87, 0.59, 0.46);
    float seams = exp(-pow((x - 0.22) * 34.0, 2.0)) * torso;
    float collar = exp(-pow((y - 0.78) * 40.0, 2.0)) * (1.0 - uncovered);
    float knee = exp(-pow((y - 0.30) * 28.0, 2.0)) * outer;
    ALBEDO = mix(cloth, skin, uncovered);
    METALLIC = mix(0.21 + boots * 0.13, 0.02, uncovered);
    ROUGHNESS = mix(0.52 - boots * 0.13, 0.72, uncovered);
    EMISSION = vec3(0.04, 0.51, 0.80) * (seams * 0.38 + collar * 0.36)
        + magenta * knee * 0.12;
    float silhouette_rim = pow(1.0 - abs(dot(normalize(NORMAL), normalize(VIEW))), 2.6);
    ALBEDO = min(ALBEDO * (1.0 + silhouette_rim * 0.18), vec3(1.0));
    EMISSION += vec3(0.10, 0.36, 0.58) * silhouette_rim * 0.20;
    // One-pass visual feedback: the actual skinned torso lights up during
    // boost, and the turn-side / airborne seams remain visible in chase view.
    float signed_x = (rest_point.x - rest_center_x) / max(rest_width, 0.001);
    float turn_side = smoothstep(0.03, 0.19, signed_x * action_carve);
    float boost_channel = exp(-pow((x - 0.19) * 14.0, 2.0)) * torso;
    float jump_channel = exp(-pow((y - 0.36) * 13.0, 2.0));
    EMISSION += vec3(0.04, 0.65, 0.95) *
        (action_boost * (0.15 * torso + 0.58 * boost_channel)
        + abs(action_carve) * turn_side * 0.34 * torso
        + action_jump * jump_channel * 0.22);
}
