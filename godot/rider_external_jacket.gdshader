shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

// V124 cohesive flight-jacket redesign on the ORIGINAL 65-bone skinned
// garment. Broad contrasting panels remain readable in mobile chase view.
// Rest-space shading needs no external texture, extra draw pass or geometry.
varying vec3 rest_vertex;
void vertex() {
    rest_vertex = VERTEX;
}
void fragment() {
    float x = abs(rest_vertex.x);
    float y = rest_vertex.y;
    float z = abs(rest_vertex.z);
    float chest = smoothstep(0.95, 1.22, y) * (1.0 - smoothstep(1.65, 1.85, y));
    float center = 1.0 - smoothstep(0.045, 0.21, x);
    float side = smoothstep(0.16, 0.34, x);
    float shoulder = smoothstep(0.21, 0.43, x) * smoothstep(1.34, 1.57, y);
    float lower_panel = 1.0 - smoothstep(1.12, 1.40, y);
    float back = smoothstep(0.12, 0.36, z);
    vec3 deep_navy = vec3(0.035, 0.065, 0.17);
    vec3 royal_violet = vec3(0.26, 0.12, 0.51);
    vec3 cobalt = vec3(0.075, 0.23, 0.44);
    vec3 electric_pink = vec3(0.61, 0.13, 0.48);
    vec3 cloth = mix(deep_navy, royal_violet, 0.32 + center * 0.62);
    cloth = mix(cloth, cobalt, side * chest * 0.76);
    cloth = mix(cloth, electric_pink, shoulder * 0.82);
    cloth = mix(cloth, vec3(0.085, 0.12, 0.27), lower_panel * 0.60);
    cloth += vec3(0.025, 0.035, 0.065) * back * chest;
    // Fine fabric relief is deliberately subtle to avoid shimmering on phones.
    float weave = sin(rest_vertex.x * 105.0) * sin(rest_vertex.y * 120.0);
    cloth *= 0.975 + 0.025 * weave;
    float zipper = exp(-pow(rest_vertex.x * 72.0, 2.0)) * chest;
    float seam = exp(-pow((x - 0.265) * 42.0, 2.0)) * chest;
    float chevron = exp(-pow((y - 1.47 + x * 0.40) * 30.0, 2.0)) * chest;
    float collar = exp(-pow((y - 1.63) * 45.0, 2.0)) * (1.0 - smoothstep(0.16, 0.34, x));
    ALBEDO = cloth;
    METALLIC = 0.15 + shoulder * 0.18;
    ROUGHNESS = 0.58 - shoulder * 0.15;
    EMISSION = vec3(0.02, 0.54, 0.80) * (zipper * 0.66 + seam * 0.48 + collar * 0.45)
        + vec3(0.58, 0.075, 0.34) * chevron * 0.32;
}
