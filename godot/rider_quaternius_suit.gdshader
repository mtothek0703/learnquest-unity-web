shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

// V124: inexpensive PBR flight-suit zones on the REAL imported skinned body.
// No extra shells, external textures, lighting passes or gameplay collisions.
// The source mesh's rest-pose coordinates are stable before GPU skinning.
varying vec3 rest_point;
void vertex() {
    rest_point = VERTEX;
}
void fragment() {
    float y = rest_point.y;
    float x = abs(rest_point.x);
    float jacket = smoothstep(0.93, 1.20, y) * (1.0 - smoothstep(1.54, 1.69, y));
    float boots = 1.0 - smoothstep(0.20, 0.40, y);
    float panels = smoothstep(0.16, 0.40, x) * jacket;
    vec3 navy = vec3(0.065, 0.085, 0.19);
    vec3 violet = vec3(0.22, 0.13, 0.49);
    vec3 cloth = mix(navy, violet, jacket * 0.82);
    cloth = mix(cloth, vec3(0.055, 0.12, 0.24), panels * 0.60);
    cloth = mix(cloth, vec3(0.035, 0.05, 0.105), boots);
    // The original body is one real skinned mesh: approximate uncovered face
    // and hands in rest space without breaking or duplicating the skin.
    float face = smoothstep(1.65, 1.77, y);
    float hands = smoothstep(0.70, 0.83, x) * smoothstep(1.19, 1.35, y)
        * (1.0 - smoothstep(1.56, 1.69, y));
    float uncovered = clamp(max(face, hands), 0.0, 1.0);
    vec3 skin = vec3(0.83, 0.53, 0.40);
    // Narrow luminous seams and collar give shape in the chase perspective.
    float seams = exp(-pow((x - 0.27) * 48.0, 2.0)) * jacket;
    float collar = exp(-pow((y - 1.58) * 42.0, 2.0)) * (1.0 - uncovered);
    float glow = max(seams * 0.55, collar * 0.40);
    ALBEDO = mix(cloth, skin, uncovered);
    METALLIC = mix(0.32, 0.02, uncovered);
    ROUGHNESS = mix(0.46, 0.68, uncovered);
    EMISSION = vec3(0.02, 0.65, 0.90) * glow;
}