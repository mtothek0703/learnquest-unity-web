shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

// V124: readable, anatomically aligned chest/shoulder panels on the actual
// GPU-skinned CC0 jacket. Rest-space bounds are passed from the imported mesh:
// no guessed fixed glTF coordinates and no external/paid textures.
uniform float rest_bottom = 0.0;
uniform float rest_height = 3.0;
uniform float rest_center_x = 0.0;
uniform float rest_width = 1.0;
varying vec3 rest_vertex;

void vertex() {
    rest_vertex = VERTEX;
}
void fragment() {
    // A coherent flight-suit identity: navy central armored body, broad
    // cobalt side panels, defined V-yoke and luminous cyan spine. This avoids
    // the previous undifferentiated violet chest in mobile chase/front views.
    float y = clamp((rest_vertex.y - rest_bottom) / max(rest_height, 0.001), 0.0, 1.0);
    float x = abs(rest_vertex.x - rest_center_x) / max(rest_width, 0.001);
    float torso = smoothstep(0.45, 0.53, y) * (1.0 - smoothstep(0.75, 0.79, y));
    float center_armor = 1.0 - smoothstep(0.11, 0.23, x);
    float flank_armor = smoothstep(0.12, 0.24, x) * (1.0 - smoothstep(0.37, 0.46, x));
    float shoulder = smoothstep(0.18, 0.29, x) * smoothstep(0.65, 0.73, y);
    float waist = 1.0 - smoothstep(0.47, 0.53, y);
    vec3 deep_navy = vec3(0.055, 0.085, 0.20);
    vec3 royal_violet = vec3(0.30, 0.16, 0.54);
    vec3 cobalt = vec3(0.13, 0.42, 0.80);
    vec3 electric_pink = vec3(0.90, 0.24, 0.54);
    vec3 cyan = vec3(0.07, 0.72, 0.97);
    vec3 cloth = mix(deep_navy, royal_violet, 0.18);
    cloth = mix(cloth, cobalt, flank_armor * torso * 0.82);
    cloth = mix(cloth, deep_navy, center_armor * torso * 0.94);
    // Shaped pectoral zones follow the actual four-weight jacket relief.
    float pectoral_panel = exp(-pow((x - 0.19) * 11.0, 2.0))
        * exp(-pow((y - 0.655) * 12.0, 2.0));
    cloth = mix(cloth, cobalt, pectoral_panel * 0.30);
    cloth = mix(cloth, electric_pink, shoulder * 0.28);
    cloth = mix(cloth, deep_navy, waist * 0.65);
    // Broad readable panel layout plus restrained material weave.
    float weave = sin(rest_vertex.x * 85.0) * sin(rest_vertex.y * 90.0);
    cloth *= 0.986 + 0.014 * weave;
    float zipper = exp(-pow(x * 66.0, 2.0)) * torso;
    float chevron = exp(-pow((y - 0.686 + x * 0.36) * 45.0, 2.0)) * torso;
    float piping = exp(-pow((x - 0.265) * 45.0, 2.0)) * torso;
    ALBEDO = cloth;
    METALLIC = 0.20 + shoulder * 0.12;
    ROUGHNESS = 0.43 + waist * 0.16;
    EMISSION = cyan * (zipper * 0.70 + chevron * 0.38 + piping * 0.24)
        + electric_pink * shoulder * 0.14;
    float silhouette_rim = pow(1.0 - abs(dot(normalize(NORMAL), normalize(VIEW))), 2.6);
    ALBEDO = min(ALBEDO * (1.0 + silhouette_rim * 0.18), vec3(1.0));
    EMISSION += vec3(0.10, 0.36, 0.58) * silhouette_rim * 0.20;
}
