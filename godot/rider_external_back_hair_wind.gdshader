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
    // Continuous dark roots and warmer strand ridges, not five painted
    // flat stripes. All dye comes from the original sculpt's vertex colors.
    float root = 1.0 - smoothstep(0.04, 0.34, hair_uv.y);
    float strand = 0.5 + 0.5 * sin(hair_uv.x * 28.0
        + hair_uv.y * 6.0);
    float tip = smoothstep(0.55, 1.0, hair_uv.y);
    vec3 base = hair_dye.rgb * hair_base_tint.rgb;
    base *= 0.88 + strand * 0.16;
    base = mix(base, hair_base_tint.rgb * 0.65, root * 0.48);
    ALBEDO = base * (1.0 - tip * 0.09);
    METALLIC = 0.015;
    ROUGHNESS = 0.66 + root * 0.09 - strand * 0.10;
    SPECULAR = 0.34;
}
