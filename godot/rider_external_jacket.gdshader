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
    float y = clamp((rest_vertex.y - rest_bottom) / max(rest_height, 0.001), 0.0, 1.0);
    float x = abs(rest_vertex.x - rest_center_x) / max(rest_width, 0.001);
    float chest = smoothstep(0.48, 0.58, y) * (1.0 - smoothstep(0.73, 0.81, y));
    float center = 1.0 - smoothstep(0.045, 0.20, x);
    float side = smoothstep(0.12, 0.29, x);
    float shoulder = smoothstep(0.085, 0.26, x) * smoothstep(0.65, 0.73, y);
    float waist = 1.0 - smoothstep(0.47, 0.56, y);
    vec3 deep_navy = vec3(0.095, 0.13, 0.30);
    vec3 royal_violet = vec3(0.53, 0.28, 0.80);
    vec3 cobalt = vec3(0.21, 0.49, 0.89);
    vec3 electric_pink = vec3(0.97, 0.32, 0.63);
    vec3 cloth = mix(deep_navy, royal_violet, 0.45 + center * 0.45);
    cloth = mix(cloth, cobalt, side * chest * 0.90);
    cloth = mix(cloth, electric_pink, shoulder * 0.90);
    // Broad curved chest panels align with the actual 3D pectoral relief.
    // Large readable surfaces remain legible at gameplay camera distance.
    float pectoral_panel = exp(-pow((x - 0.17) * 9.0, 2.0))
        * exp(-pow((y - 0.655) * 11.0, 2.0));
    cloth = mix(cloth, cobalt, pectoral_panel * 0.37);
    cloth = mix(cloth, deep_navy, waist * 0.22);
    // Large material regions, rather than tiny high-frequency stripes, must
    // read in both smartphone landscape chase and front perspectives.
    float weave = sin(rest_vertex.x * 85.0) * sin(rest_vertex.y * 90.0);
    cloth *= 0.985 + 0.015 * weave;
    float zipper = exp(-pow(x * 55.0, 2.0)) * chest;
    float piping = exp(-pow((x - 0.205) * 38.0, 2.0)) * chest;
    float chevron = exp(-pow((y - 0.665 + x * 0.28) * 26.0, 2.0)) * chest;
    ALBEDO = cloth;
    METALLIC = 0.12 + shoulder * 0.20;
    ROUGHNESS = 0.58 - shoulder * 0.17;
    EMISSION = vec3(0.04, 0.53, 0.85) * (zipper * 0.48 + piping * 0.52)
        + vec3(0.60, 0.06, 0.35) * chevron * 0.32;
    // Single-pass, camera-relative contour lift for readable skinned limbs
    // in mobile landscape. No outline shell, light, texture or extra draw call.
    float silhouette_rim = pow(1.0 - abs(dot(normalize(NORMAL), normalize(VIEW))), 2.6);
    ALBEDO = min(ALBEDO * (1.0 + silhouette_rim * 0.18), vec3(1.0));
    EMISSION += vec3(0.10, 0.36, 0.58) * silhouette_rim * 0.20;
}
