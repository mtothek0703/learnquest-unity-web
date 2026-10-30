shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;
// V124 DRAFT: one-pass secondary motion on the ORIGINAL four-weight CC0 hair.
// UV.y is root-to-tip distance in the sculpted rest mesh. Skinning stays
// enabled by Godot after this small, root-anchored local-space displacement.
uniform float steer_amount : hint_range(-1.0, 1.0) = 0.0;
uniform float boost_amount : hint_range(0.0, 1.0) = 0.0;
uniform float jump_amount : hint_range(0.0, 1.0) = 0.0;
uniform float motion_phase = 0.0;
uniform float wind_back_sign : hint_range(-1.0, 1.0) = 1.0;
// The original StandardMaterial multiplied the sculpt's COLOR by a very dark
// chestnut albedo. Preserve that factor when moving to a ShaderMaterial.
uniform vec4 hair_base_tint : source_color = vec4(0.065, 0.048, 0.060, 1.0);
varying vec2 hair_uv;
varying vec4 hair_dye;

void vertex() {
    hair_uv = UV;
    hair_dye = COLOR;
    float tip = smoothstep(0.14, 0.98, UV.y);
    float flutter = tip * tip;
    float wave = sin(motion_phase * (2.2 + boost_amount * 1.7)
        + UV.x * 8.0 + UV.y * 4.2);
    // Zero displacement at scalp. Boost and carve produce distinct, modest
    // 3D motion; the original Head/Neck/Spine skin still owns the main pose.
    VERTEX.x += flutter * (steer_amount * 0.042
        + wave * (0.006 + boost_amount * 0.020));
    VERTEX.z += wind_back_sign * flutter *
        (boost_amount * 0.032 + jump_amount * 0.016);
}

void fragment() {
    // A unified dark-chestnut fiber finish across the weighted curtain and
    // all five true-skinned locks. Low-frequency strand groups give volume;
    // fine fibers add directionality without extra geometry, textures, passes
    // or bright painted ribbons. Both frequencies follow the same root-to-tip
    // UVs in the imported Head/Neck/Spine rest pose.
    float root = 1.0 - smoothstep(0.04, 0.34, hair_uv.y);
    float tip = smoothstep(0.58, 1.0, hair_uv.y);
    float broad = 0.5 + 0.5 * sin(hair_uv.x * 17.0
        + hair_uv.y * 4.0 + sin(hair_uv.y * 7.0) * 0.4);
    float fibers = 0.5 + 0.5 * sin(hair_uv.x * 109.0
        + hair_uv.y * 14.0 + broad * 2.2);
    float directional = pow(1.0 - abs(dot(normalize(NORMAL),
        normalize(VIEW))), 2.5);
    vec3 original_dye = hair_dye.rgb * hair_base_tint.rgb;
    // Melanin-like tonal layering: deep roots, warm mid-shafts and subtly
    // translucent-looking tips. Keep the original dark dye, not an unbounded
    // white specular/albedo wash (previously caught by real OpenGL frames).
    float tonal = 0.82 + 0.19 * broad + 0.075 * fibers;
    vec3 base = original_dye * tonal;
    base = mix(base, original_dye * 0.66, root * 0.68);
    base *= 1.0 - tip * 0.075;
    base += original_dye * directional * (0.08 + 0.10 * fibers)
        * (1.0 - root * 0.75);
    // Root-to-tip pigment and narrow fiber sheen are applied directly to
    // the REAL skinned hair curtain and five weighted locks. The previous
    // dark-on-dark double tint disappeared in the chase camera; bounded
    // plum/copper glints restore strand separation without white bleaching.
    float fiber_sheen = pow(0.5 + 0.5 * sin(hair_uv.x * 23.0
        + hair_uv.y * 5.5 + broad * 1.7), 5.0);
    float colored_length = smoothstep(0.18, 0.42, hair_uv.y)
        * (1.0 - smoothstep(0.90, 1.0, hair_uv.y));
    vec3 dyed_chestnut = max(base, hair_base_tint.rgb * (0.60 + 0.18 * broad));
    vec3 plum_copper = mix(vec3(0.20, 0.075, 0.25),
        vec3(0.27, 0.12, 0.20), fibers);
    vec3 highlight = plum_copper * fiber_sheen * colored_length
        * (0.22 + 0.12 * boost_amount);
    ALBEDO = min(dyed_chestnut + highlight, vec3(0.27, 0.18, 0.29));
    // PBR fiber glints stay light-reactive (not emissive), preserving
    // depth under the existing scene lighting and mobile render budget.
    METALLIC = 0.012;
    ROUGHNESS = clamp(0.64 + root * 0.14 - broad * 0.10
        - fibers * 0.045 + tip * 0.06, 0.45, 0.84);
    SPECULAR = 0.40 + 0.14 * fiber_sheen * colored_length;
}
