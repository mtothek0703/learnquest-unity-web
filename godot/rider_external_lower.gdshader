shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;
// Matching trousers/hoverboots on the original four-weight 65-bone Skin.
// High-contrast shin piping is visible from behind without extra meshes.
uniform float boot_mode : hint_range(0.0, 1.0) = 0.0;
varying vec3 source_vertex;
void vertex() {
    source_vertex = VERTEX;
}
void fragment() {
    float x = abs(source_vertex.x);
    float y = source_vertex.y;
    float z = abs(source_vertex.z);
    float outer_leg = smoothstep(0.13, 0.27, x);
    float knee = exp(-pow((y - 0.74) * 10.0, 2.0));
    float cuff = exp(-pow((y - 0.38) * 17.0, 2.0));
    float heel = smoothstep(0.16, 0.34, z);
    vec3 midnight = vec3(0.035, 0.06, 0.16);
    vec3 violet = vec3(0.20, 0.105, 0.41);
    vec3 cobalt = vec3(0.055, 0.22, 0.42);
    vec3 magenta = vec3(0.44, 0.13, 0.36);
    vec3 trousers = mix(midnight, violet, 0.36 + outer_leg * 0.45);
    trousers = mix(trousers, cobalt, knee * 0.65);
    vec3 boots = mix(midnight, cobalt, 0.36 + heel * 0.44);
    boots = mix(boots, magenta, cuff * 0.60);
    ALBEDO = mix(trousers, boots, boot_mode);
    METALLIC = mix(0.15, 0.32, boot_mode);
    ROUGHNESS = mix(0.59, 0.39, boot_mode);
    float edge = exp(-pow((x - 0.195) * 42.0, 2.0));
    float shin = exp(-pow((x - 0.13) * 40.0, 2.0)) * smoothstep(0.20, 0.50, y);
    EMISSION = vec3(0.02, 0.50, 0.77) * (edge * 0.50 + shin * 0.32)
        + vec3(0.44, 0.065, 0.28) * cuff * boot_mode * 0.34;
}
