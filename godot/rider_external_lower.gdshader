shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;
// Both meshes are generated with the original four-weight Skin/bind poses.
uniform float boot_mode : hint_range(0.0, 1.0) = 0.0;
varying vec3 source_vertex;
void vertex() {
    source_vertex = VERTEX;
}
void fragment() {
    float piping = exp(-pow((abs(source_vertex.x) - 0.19) * 32.0, 2.0));
    float knee = exp(-pow((source_vertex.y - 0.72) * 9.0, 2.0));
    vec3 trouser_base = mix(vec3(0.055, 0.075, 0.17), vec3(0.17, 0.09, 0.35),
        clamp(0.35 + 0.6 * abs(source_vertex.x), 0.0, 1.0));
    vec3 boot_base = mix(vec3(0.035, 0.055, 0.12), vec3(0.11, 0.15, 0.27),
        clamp(0.5 + source_vertex.z * 0.7, 0.0, 1.0));
    ALBEDO = mix(trouser_base + vec3(0.04, 0.03, 0.07) * knee, boot_base, boot_mode);
    METALLIC = mix(0.16, 0.35, boot_mode);
    ROUGHNESS = mix(0.64, 0.42, boot_mode);
    EMISSION = vec3(0.015, 0.32, 0.53) * piping * mix(0.35, 0.72, boot_mode);
}
