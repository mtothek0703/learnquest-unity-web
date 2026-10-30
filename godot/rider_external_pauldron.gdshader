shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;
// Shared action lighting on the original GPU-skinned hero; no extra meshes.
uniform float action_boost : hint_range(0.0, 1.0) = 0.0;
uniform float action_carve : hint_range(-1.0, 1.0) = 0.0;
uniform float action_jump : hint_range(0.0, 1.0) = 0.0;

// A single mobile PBR pass on a genuinely skinned, closed shoulder volume.
// COLOR comes from the 3D shell; UV supplies broad readable panel divisions.
varying vec4 dye;
varying vec2 panel_uv;
void vertex() {
    dye = COLOR;
    panel_uv = UV;
}
void fragment() {
    float upper = 1.0 - smoothstep(0.23, 0.55, panel_uv.y);
    float lower = smoothstep(0.56, 0.92, panel_uv.y);
    float leading = exp(-pow((panel_uv.x - 0.03) * 19.0, 2.0))
        + exp(-pow((panel_uv.x - 0.97) * 19.0, 2.0));
    float rib = exp(-pow((panel_uv.y - 0.47) * 25.0, 2.0));
    vec3 navy = vec3(0.055, 0.075, 0.19);
    vec3 purple = vec3(0.36, 0.17, 0.62);
    vec3 cobalt = vec3(0.18, 0.39, 0.82);
    vec3 pink = vec3(0.92, 0.24, 0.63);
    vec3 shell = mix(navy, dye.rgb, 0.85);
    shell = mix(shell, purple, upper * 0.68);
    shell = mix(shell, cobalt, rib * 0.40);
    shell = mix(shell, navy, lower * 0.38);
    // The shoulder ridge continues the vivid chest V into both silhouettes.
    float hero_shoulder_crest = upper * (1.0 - smoothstep(0.27, 0.68, panel_uv.x));
    shell = mix(shell, pink, hero_shoulder_crest * 0.31);
    ALBEDO = shell;
    METALLIC = 0.38 + upper * 0.18;
    ROUGHNESS = 0.36 + lower * 0.12;
    EMISSION = vec3(0.06, 0.67, 0.98) * (leading * 0.26 + rib * 0.18)
        + pink * upper * 0.06;
    EMISSION += vec3(0.06, 0.68, 0.98) *
        (action_boost * (0.20 + 0.30 * upper)
        + abs(action_carve) * leading * 0.20)
        + pink * action_jump * lower * 0.13;
}
