shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;
// Original 65-bone GPU skinning deforms the organic sleeve triangles.
// Per-vertex COLOR.r is original upper-arm weight; no external textures.
uniform float side = 1.0;
varying float shoulder_weight;
varying float arm_weight;
varying vec3 source_position;
void vertex() {
    shoulder_weight = COLOR.r;
    arm_weight = COLOR.g;
    source_position = VERTEX;
}
void fragment() {
    float shoulder = smoothstep(0.30, 0.92, shoulder_weight);
    float forearm = 1.0 - smoothstep(0.08, 0.48, shoulder_weight);
    float piping = exp(-pow((shoulder_weight - 0.54) * 10.0, 2.0));
    float fabric = smoothstep(0.35, 0.80, arm_weight);
    vec3 midnight = vec3(0.035, 0.065, 0.17);
    vec3 cobalt = vec3(0.095, 0.29, 0.64);
    vec3 violet = vec3(0.32, 0.16, 0.59);
    vec3 color = mix(midnight, cobalt, shoulder * 0.92);
    color = mix(color, violet, forearm * 0.52);
    ALBEDO = color * (0.84 + 0.16 * fabric);
    METALLIC = mix(0.15, 0.31, shoulder);
    ROUGHNESS = mix(0.61, 0.42, shoulder);
    EMISSION = vec3(0.03, 0.57, 0.90) * piping * 0.28;
}
