shader_type spatial;

// Neon City authored facade material, mobile Compatibility renderer.
// Single shader on each tower: 2-sided windows, vertical mullions,
// varied occupied/unoccupied rooms, warm/cool interior light and trim.
// Procedural shading avoids 150+ independent window MeshInstances.
uniform vec4 panel_tint : source_color = vec4(0.08, 0.13, 0.26, 1.0);
uniform vec4 cyan_light : source_color = vec4(0.23, 0.83, 0.95, 1.0);
uniform vec4 warm_light : source_color = vec4(1.0, 0.62, 0.31, 1.0);
uniform float facade_seed = 0.0;
uniform float rows = 13.0;
uniform float columns = 7.0;

varying vec3 local_normal;

float hash21(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void vertex() {
    local_normal = NORMAL;
}

void fragment() {
    float rooftop = step(0.75, abs(local_normal.y));
    vec2 tiles = vec2(UV.x * columns, UV.y * rows);
    vec2 room_id = floor(tiles);
    vec2 within = fract(tiles);
    float random_light = hash21(room_id + vec2(facade_seed, facade_seed * 1.73));
    float random_side = hash21(room_id.yx + vec2(facade_seed * 2.7, 19.0));

    // Thin recessed window, inset frames and dark vertical structure.
    float glass = step(0.19, within.x) * (1.0 - step(0.80, within.x))
                * step(0.18, within.y) * (1.0 - step(0.78, within.y));
    float lit = step(0.37, random_light);
    float pane_mid = step(0.488, within.x) * (1.0 - step(0.512, within.x));
    float sill = step(0.77, within.y) * (1.0 - step(0.82, within.y));
    float vertical_fin = 1.0 - step(0.027, fract(UV.x * (columns * 0.5)));
    float border = max(pane_mid, sill);
    float detail = mix(0.90, 1.11, hash21(room_id * 0.27 + facade_seed));
    vec3 facade = panel_tint.rgb * detail;
    facade *= mix(1.0, 0.67, clamp(vertical_fin, 0.0, 1.0));
    vec3 dark_glass = vec3(0.015, 0.040, 0.097);
    vec3 lit_glass = mix(cyan_light.rgb, warm_light.rgb, step(0.79, random_side));
    vec3 glass_color = mix(dark_glass, lit_glass * 0.66, lit);
    facade = mix(facade, glass_color, glass * (1.0 - border * 0.60));

    // Rooftops have real flat roofing, not glass windows facing up.
    facade = mix(facade, panel_tint.rgb * 0.40, rooftop);
    ALBEDO = facade;
    ROUGHNESS = mix(0.78, 0.32, glass);
    METALLIC = 0.08;
    EMISSION = lit_glass * glass * lit * 1.55 * (1.0 - rooftop);
}
