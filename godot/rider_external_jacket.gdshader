shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

// PBR textile + angular flight panels on an ACTUAL weighted garment surface.
// The geometry and its 4-weight skinning are generated from CC0 body triangles.
varying vec3 rest_vertex;
void vertex() {
    rest_vertex = VERTEX;
}
void fragment() {
    float center = 1.0 - smoothstep(0.05, 0.29, abs(rest_vertex.x));
    float seams = exp(-pow((abs(rest_vertex.x) - 0.24) * 45.0, 2.0));
    float diagonal = exp(-pow((abs(rest_vertex.x) * 0.9 + rest_vertex.y * 0.22 - 0.42) * 42.0, 2.0));
    vec3 violet = vec3(0.23, 0.11, 0.47);
    vec3 navy = vec3(0.055, 0.08, 0.19);
    vec3 cloth = mix(navy, violet, center * 0.74);
    cloth = mix(cloth, vec3(0.11, 0.17, 0.34), diagonal * 0.68);
    ALBEDO = cloth;
    METALLIC = 0.22;
    ROUGHNESS = 0.51;
    EMISSION = vec3(0.025, 0.45, 0.74) * seams * 0.62;
}
