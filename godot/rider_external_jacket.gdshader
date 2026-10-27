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
    vec3 deep_navy = vec3(0.045, 0.075, 0.19);
    vec3 royal_violet = vec3(0.37, 0.17, 0.64);
    vec3 cobalt = vec3(0.10, 0.36, 0.72);
    vec3 electric_pink = vec3(0.91, 0.16, 0.53);
    vec3 cloth = mix(deep_navy, royal_violet, 0.45 + center * 0.45);
    cloth = mix(cloth, cobalt, side * chest * 0.90);
    cloth = mix(cloth, electric_pink, shoulder * 0.90);
    cloth = mix(cloth, deep_navy, waist * 0.38);
    // Large material regions, rather than tiny high-frequency stripes, must
    // read in both smartphone landscape chase and front perspectives.
    float weave = sin(rest_vertex.x * 85.0) * sin(rest_vertex.y * 90.0);
    cloth *= 0.975 + 0.025 * weave;
    float zipper = exp(-pow(x * 55.0, 2.0)) * chest;
    float piping = exp(-pow((x - 0.205) * 38.0, 2.0)) * chest;
    float chevron = exp(-pow((y - 0.665 + x * 0.28) * 26.0, 2.0)) * chest;
    ALBEDO = cloth;
    METALLIC = 0.12 + shoulder * 0.20;
    ROUGHNESS = 0.58 - shoulder * 0.17;
    EMISSION = vec3(0.04, 0.53, 0.85) * (zipper * 0.48 + piping * 0.52)
        + vec3(0.60, 0.06, 0.35) * chevron * 0.32;
}
