shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;
// V124: a broad, bone-skinned split-wing flight mantle. Wind deformation is
// cosmetic, cheap in WebGL and tied to the existing rider pose (no physics).
uniform float side : hint_range(-1.0, 1.0) = 1.0;
uniform float wind_back_sign : hint_range(-1.0, 1.0) = 1.0;
uniform float steer_amount : hint_range(-1.0, 1.0) = 0.0;
uniform float boost_amount : hint_range(0.0, 1.0) = 0.0;
uniform float jump_amount : hint_range(0.0, 1.0) = 0.0;
varying vec2 cloth_uv;
void vertex() {
    cloth_uv = UV;
    float trailing = smoothstep(0.12, 1.0, UV.y);
    float flutter = trailing * trailing;
    float wave = sin(TIME * (2.2 + boost_amount * 2.4) + UV.y * 9.0 + UV.x * 5.5 + side * 0.7);
    VERTEX.x += side * wave * (0.012 + boost_amount * 0.027) * flutter;
    VERTEX.x += steer_amount * 0.050 * trailing;
    VERTEX.z += wind_back_sign * (0.018 + boost_amount * 0.045 + jump_amount * 0.020) * trailing;
    VERTEX.z += sin(TIME * 3.1 + UV.y * 9.0 + UV.x * 6.0) * 0.024 * flutter;
    VERTEX.y += sin(TIME * 2.6 + UV.y * 7.0) * 0.010 * flutter + jump_amount * 0.024 * trailing;
}
void fragment() {
    // One continuous high-contrast airfoil: a dark load-bearing wing, a
    // cobalt mid-chord, an illuminated leading spar and a magenta trailing
    // feather. This replaces the old flat purple skirt silhouette without
    // adding draw passes, texture assets, lights or mobile overdraw layers.
    float leading = 1.0 - smoothstep(0.025, 0.10, cloth_uv.x);
    float trailing = smoothstep(0.86, 0.985, cloth_uv.x);
    float tip = smoothstep(0.83, 1.0, cloth_uv.y);
    float central_spar = exp(-pow((cloth_uv.x - 0.43) * 12.0, 2.0));
    float chord = smoothstep(0.08, 0.24, cloth_uv.x)
        * (1.0 - smoothstep(0.78, 0.96, cloth_uv.x));
    float fold = 0.5 + 0.5 * sin(cloth_uv.x * 8.0 + cloth_uv.y * 3.0);
    float root = 1.0 - smoothstep(0.08, 0.28, cloth_uv.y);
    vec3 midnight = vec3(0.045, 0.072, 0.17);
    vec3 cobalt = vec3(0.13, 0.36, 0.72);
    vec3 violet = vec3(0.36, 0.19, 0.60);
    vec3 cyan = vec3(0.035, 0.72, 0.98);
    vec3 magenta = vec3(0.88, 0.18, 0.52);
    vec3 shell = mix(midnight, cobalt, chord * (0.67 + fold * 0.13));
    shell = mix(shell, violet, central_spar * 0.38);
    shell = mix(shell, magenta, trailing * (0.70 + 0.12 * tip));
    shell = mix(shell, midnight, root * 0.56);
    ALBEDO = shell;
    METALLIC = mix(0.23, 0.40, central_spar);
    ROUGHNESS = 0.39 + 0.12 * fold;
    EMISSION = cyan * (leading * 0.62 + central_spar * 0.30)
        + magenta * (trailing * 0.36 + tip * 0.12);
    float silhouette_rim = pow(1.0 - abs(dot(normalize(NORMAL), normalize(VIEW))), 2.6);
    ALBEDO = min(ALBEDO * (1.0 + silhouette_rim * 0.17), vec3(1.0));
    EMISSION += vec3(0.11, 0.33, 0.60) * silhouette_rim * 0.17;
}
