shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;
// V124 unreleased: coordinated, large readable leg and boot material zones.
// All coordinates are normalized against the real imported CC0 body bounds.
// The geometry underneath remains the original four-weight 65-bone Skin.
uniform float boot_mode : hint_range(0.0, 1.0) = 0.0;
uniform float rest_bottom = 0.0;
uniform float rest_height = 3.0;
uniform float rest_center_x = 0.0;
uniform float rest_width = 1.0;
varying vec3 source_vertex;
void vertex() {
    source_vertex = VERTEX;
}
void fragment() {
    float y = clamp((source_vertex.y - rest_bottom) / max(rest_height, 0.001), 0.0, 1.0);
    float x = abs(source_vertex.x - rest_center_x) / max(rest_width, 0.001);
    float outside = smoothstep(0.13, 0.30, x);
    float center = 1.0 - smoothstep(0.08, 0.21, x);
    float thigh = smoothstep(0.31, 0.38, y);
    float knee = exp(-pow((y - 0.305) * 22.0, 2.0));
    float shin = smoothstep(0.18, 0.25, y) * (1.0 - smoothstep(0.34, 0.41, y));
    float toe = 1.0 - smoothstep(0.065, 0.14, y);
    vec3 cobalt = vec3(0.15, 0.37, 0.77);
    vec3 violet = vec3(0.40, 0.22, 0.67);
    vec3 midnight = vec3(0.055, 0.09, 0.23);
    vec3 magenta = vec3(0.92, 0.20, 0.53);
    vec3 titanium = vec3(0.36, 0.49, 0.70);
    vec3 trousers = mix(cobalt, violet, outside * 0.75);
    trousers = mix(trousers, midnight, center * 0.22);
    trousers = mix(trousers, titanium, knee * 0.65);
    vec3 boots = mix(cobalt, titanium, toe * 0.78);
    boots = mix(boots, violet, shin * 0.40);
    boots = mix(boots, magenta, outside * (1.0 - toe) * 0.35);
    ALBEDO = mix(trousers, boots, boot_mode);
    METALLIC = mix(0.16, 0.35, boot_mode);
    ROUGHNESS = mix(0.51, 0.38, boot_mode);
    float edge = exp(-pow((x - 0.225) * 32.0, 2.0));
    float stripe = exp(-pow((x - 0.28) * 28.0, 2.0)) * thigh;
    EMISSION = vec3(0.03, 0.54, 0.88) * (edge * 0.30 + stripe * 0.23)
        + magenta * knee * outside * 0.12;
    // Single-pass, camera-relative contour lift for readable skinned limbs
    // in mobile landscape. No outline shell, light, texture or extra draw call.
    float silhouette_rim = pow(1.0 - abs(dot(normalize(NORMAL), normalize(VIEW))), 2.6);
    ALBEDO = min(ALBEDO * (1.0 + silhouette_rim * 0.18), vec3(1.0));
    EMISSION += vec3(0.10, 0.32, 0.58) * silhouette_rim * 0.16;
}
