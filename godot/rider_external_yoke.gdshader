shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;
// Sculpted four-weight source-body yoke: metallic shoulders and fabric collar.
// Normalized rest-pose coordinates keep the design aligned with the CC0 mesh.
uniform float rest_bottom = 0.0;
uniform float rest_height = 2.0;
uniform float rest_center_x = 0.0;
uniform float rest_width = 2.0;
varying vec3 rest_point;
void vertex() {
    rest_point = VERTEX;
}
void fragment() {
    float y = (rest_point.y - rest_bottom) / max(rest_height, 0.01);
    float x = abs(rest_point.x - rest_center_x) / max(rest_width, 0.01);
    float shoulder = smoothstep(0.075, 0.19, x);
    float central = 1.0 - smoothstep(0.07, 0.20, x);
    float collar = exp(-pow((y - 0.765) * 82.0, 2.0));
    float piping = exp(-pow((x - 0.16) * 60.0, 2.0));
    float seam = exp(-pow((y - 0.642) * 78.0, 2.0));
    vec3 graphite = vec3(0.055, 0.09, 0.19);
    vec3 titanium = vec3(0.19, 0.24, 0.42);
    vec3 violet = vec3(0.22, 0.12, 0.45);
    vec3 surface_color = mix(graphite, titanium, shoulder * 0.85);
    surface_color = mix(surface_color, violet, central * 0.42);
    // Tie the actual four-weight shoulder yoke into the jacket's dark
    // stitched collar and satin plate finish instead of a floating neon cap.
    float shoulder_plate = shoulder * smoothstep(0.64, 0.72, y);
    float collar_gasket = exp(-pow((y - 0.751) * 110.0, 2.0)) * central;
    float plate_recess = exp(-pow((x - 0.245) * 72.0, 2.0))
        * smoothstep(0.63, 0.70, y);
    surface_color = mix(surface_color, vec3(0.21, 0.30, 0.44),
        shoulder_plate * 0.55);
    surface_color = mix(surface_color, vec3(0.022, 0.037, 0.072),
        clamp(collar_gasket * 0.74 + plate_recess * 0.72, 0.0, 0.9));
    ALBEDO = surface_color;
    METALLIC = mix(0.18, 0.58, shoulder_plate);
    ROUGHNESS = clamp(0.55 - shoulder_plate * 0.23
        + collar_gasket * 0.17 + plate_recess * 0.12, 0.29, 0.76);
    EMISSION = vec3(0.02, 0.48, 0.81) * max(collar * 0.36, max(piping * 0.52, seam * 0.20));
    // Single-pass, camera-relative contour lift for readable skinned limbs
    // in mobile landscape. No outline shell, light, texture or extra draw call.
    float silhouette_rim = pow(1.0 - abs(dot(normalize(NORMAL), normalize(VIEW))), 2.6);
    ALBEDO = min(ALBEDO * (1.0 + silhouette_rim * 0.18), vec3(1.0));
    EMISSION += vec3(0.17, 0.31, 0.52) * silhouette_rim * 0.16;
}
