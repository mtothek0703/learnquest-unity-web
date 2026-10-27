shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;
// The original 65-bone GPU skinning bends the real sculpted CC0 triangles.
// COLOR.r = shoulder influence, COLOR.g = total arm influence,
// COLOR.b = modeled armor panel mask (shoulder, elbow and forearm).
// No texture download, rigid props, extra lights or additional passes.
uniform float side = 1.0;
varying float shoulder_weight;
varying float arm_weight;
varying float panel_mask;
void vertex() {
    shoulder_weight = COLOR.r;
    arm_weight = COLOR.g;
    panel_mask = COLOR.b;
}
void fragment() {
    float shoulder = smoothstep(0.30, 0.90, shoulder_weight);
    float forearm = 1.0 - smoothstep(0.12, 0.55, shoulder_weight);
    float panel = smoothstep(0.20, 0.84, panel_mask);
    float joint = exp(-pow((shoulder_weight - 0.48) * 11.0, 2.0));
    vec3 midnight = vec3(0.08, 0.12, 0.27);
    vec3 cobalt = vec3(0.22, 0.48, 0.88);
    vec3 violet = vec3(0.53, 0.28, 0.80);
    vec3 titanium = vec3(0.34, 0.43, 0.61);
    vec3 cloth = mix(midnight, cobalt, shoulder * 0.75 + forearm * 0.15);
    vec3 armor = mix(titanium, violet, forearm * 0.60);
    vec3 color = mix(cloth, armor, panel * 0.87);
    color *= 0.97 + 0.03 * arm_weight;
    ALBEDO = color;
    METALLIC = mix(0.14, 0.53, panel);
    ROUGHNESS = mix(0.64, 0.34, panel);
    // Wide but restrained emissive piping remains legible on phone screens.
    float edge = smoothstep(0.34, 0.52, panel_mask) *
        (1.0 - smoothstep(0.65, 0.84, panel_mask));
    EMISSION = vec3(0.035, 0.58, 0.90) * (edge * 0.37 + joint * 0.10);
    // Single-pass, camera-relative contour lift for readable skinned limbs
    // in mobile landscape. No outline shell, light, texture or extra draw call.
    float silhouette_rim = pow(1.0 - abs(dot(normalize(NORMAL), normalize(VIEW))), 2.6);
    ALBEDO = min(ALBEDO * (1.0 + silhouette_rim * 0.18), vec3(1.0));
    EMISSION += vec3(0.24, 0.19, 0.51) * silhouette_rim * 0.20;
}
