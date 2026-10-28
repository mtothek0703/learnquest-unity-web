shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;
// V124 draft: dark articulated shin guards, distinct titanium forefeet,
// narrow ankle fabric and a thin luminous calf rim. One mobile draw pass.
// Original 65-bone GPU skinning and source garment dimensions are untouched.
uniform float boot_mode : hint_range(0.0, 1.0) = 0.0;
uniform float face_sign = -1.0;
uniform float rest_bottom = 0.0;
uniform float rest_height = 3.0;
uniform float rest_center_x = 0.0;
uniform float rest_width = 1.0;
varying vec3 source_vertex;
varying float forward_surface;
void vertex() {
    source_vertex = VERTEX;
    forward_surface = clamp(NORMAL.z * face_sign, 0.0, 1.0);
}
void fragment() {
    float y = clamp((source_vertex.y - rest_bottom) / max(rest_height, 0.001), 0.0, 1.0);
    float x = abs(source_vertex.x - rest_center_x) / max(rest_width, 0.001);
    float outside = smoothstep(0.12, 0.28, x);
    float center = 1.0 - smoothstep(0.07, 0.21, x);
    float thigh = smoothstep(0.31, 0.38, y);
    float knee = exp(-pow((y - 0.305) * 23.0, 2.0));
    float calf = exp(-pow((y - 0.225) * 20.0, 2.0));
    float ankle = exp(-pow((y - 0.151) * 37.0, 2.0));
    float ankle_cuff = exp(-pow((y - 0.246) * 91.0, 2.0));
    float shin_plate = calf * forward_surface * (0.65 + 0.35 * outside);
    float forefoot = exp(-pow((y - 0.088) * 25.0, 2.0)) * forward_surface;
    float heel_counter = exp(-pow((y - 0.069) * 30.0, 2.0)) * (1.0 - forward_surface);
    float sole_edge = exp(-pow((y - 0.045) * 72.0, 2.0));
    float toe_cap = exp(-pow((y - 0.088) * 21.0, 2.0));
    vec3 cobalt = vec3(0.15, 0.37, 0.77);
    vec3 violet = vec3(0.40, 0.22, 0.67);
    vec3 midnight = vec3(0.045, 0.075, 0.18);
    vec3 magenta = vec3(0.92, 0.20, 0.53);
    vec3 titanium = vec3(0.36, 0.49, 0.70);
    vec3 trousers = mix(cobalt, violet, outside * 0.75);
    trousers = mix(trousers, midnight, center * 0.22);
    trousers = mix(trousers, titanium, knee * 0.65);
    // Break the previous uniformly bright blue calf-to-foot tube into four
    // physically modeled regions with sharply differentiated material values.
    vec3 boots = mix(midnight, cobalt, outside * 0.35);
    boots = mix(boots, violet, calf * outside * 0.18);
    boots = mix(boots, vec3(0.035, 0.065, 0.15), shin_plate * 0.88);
    boots = mix(boots, midnight, ankle * 0.72);
    boots = mix(boots, titanium, toe_cap * 0.82);
    boots = mix(boots, vec3(0.12, 0.30, 0.51), forefoot * 0.34);
    boots = mix(boots, titanium, heel_counter * 0.54);
    boots = mix(boots, vec3(0.10, 0.15, 0.27), sole_edge * 0.88);
    boots = mix(boots, vec3(0.23, 0.48, 0.69), ankle_cuff * 0.60);
    ALBEDO = mix(trousers, boots, boot_mode);
    METALLIC = mix(0.16, 0.43, boot_mode);
    ROUGHNESS = mix(0.51, 0.39, boot_mode);
    float edge = exp(-pow((x - 0.225) * 32.0, 2.0));
    float stripe = exp(-pow((x - 0.28) * 28.0, 2.0)) * thigh;
    float shin_seam = exp(-pow((x - 0.235) * 45.0, 2.0)) * calf;
    EMISSION = vec3(0.03, 0.54, 0.88) * (edge * 0.30 + stripe * 0.23) * (1.0 - boot_mode)
        + magenta * knee * outside * 0.12
        + vec3(0.02, 0.65, 0.98) * ankle_cuff * boot_mode * 0.24
        + vec3(0.04, 0.38, 0.67) * shin_seam * boot_mode * 0.22;
    float silhouette_rim = pow(1.0 - abs(dot(normalize(NORMAL), normalize(VIEW))), 2.6);
    ALBEDO = min(ALBEDO * (1.0 + silhouette_rim * 0.16), vec3(1.0));
    EMISSION += vec3(0.10, 0.32, 0.58) * silhouette_rim * 0.12;
}
