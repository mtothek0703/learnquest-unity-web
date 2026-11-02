extends Node
## V124: reshape the ORIGINAL CC0 four-weight body in rest space, rather
## than stacking another unrigged torso prop. All original Skin binds, bone
## indices, weights, triangle indices and draw-call count are preserved.
## This is a reversible runtime-only silhouette trial; the CC0 GLB on disk
## and every previously released Skyway build remain untouched.
var source_mesh: Mesh
var sculpted_mesh: ArrayMesh
var sculpted_vertices: int = 0
var source_vertices: int = 0

func install(meshes: Array[MeshInstance3D]) -> bool:
    for body in meshes:
        if body == null or body.mesh == null or body.skin == null:
            continue
        if not String(body.name).contains("SuperHero"):
            continue
        var original := body.mesh
        if original.get_blend_shape_count() != 0:
            return false # Never discard imported morph targets.
        var bounds := original.get_aabb()
        if bounds.size.x < 0.1 or bounds.size.y < 0.5 or bounds.size.z < 0.05:
            return false
        var replacement := ArrayMesh.new()
        var total := 0
        var changed := 0
        for surface in range(original.get_surface_count()):
            if original.surface_get_primitive_type(surface) != Mesh.PRIMITIVE_TRIANGLES:
                return false
            var arrays: Array = original.surface_get_arrays(surface)
            var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
            var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
            var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
            var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
            if vertices.is_empty() or normals.size() != vertices.size() or \
                    bones.size() != vertices.size() * 4 or weights.size() != vertices.size() * 4:
                return false
            var reshaped := PackedVector3Array()
            var smooth_normals := PackedVector3Array()
            for i in range(vertices.size()):
                var old := vertices[i]
                var new_point := _reshape(old, bounds)
                reshaped.append(new_point)
                # Central differences approximate the full nonuniform sculpt
                # Jacobian; inverse-transpose gives lighting normals that
                # follow the new curved anatomy without adding a shader pass.
                smooth_normals.append(_normal(old, normals[i], bounds))
                if old.distance_squared_to(new_point) > 0.00000001:
                    changed += 1
            arrays[Mesh.ARRAY_VERTEX] = reshaped
            arrays[Mesh.ARRAY_NORMAL] = smooth_normals
            replacement.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
            replacement.surface_set_material(surface, original.surface_get_material(surface))
            total += vertices.size()
        if total < 1000 or changed < 200:
            return false
        # Atomic swap only after every source surface has been validated.
        source_mesh = original
        sculpted_mesh = replacement
        source_vertices = total
        sculpted_vertices = changed
        body.mesh = replacement
        return true
    return false

func _reshape(point: Vector3, bounds: AABB) -> Vector3:
    var y := (point.y - bounds.position.y) / bounds.size.y
    var x := (point.x - bounds.get_center().x) / (bounds.size.x * 0.5)
    var side := absf(x)
    # Leave arms/hands outside the fitted torso envelope unchanged. The
    # narrow waist, fuller pectorals, deltoids, hips and thighs form one
    # continuous source mesh rather than disconnected armor capsules.
    var torso := 1.0 - smoothstep(0.20, 0.39, side)
    var leg := 1.0 - smoothstep(0.22, 0.42, side)
    var chest := exp(-pow((y - 0.665) / 0.078, 2.0))
    var shoulder := exp(-pow((y - 0.738) / 0.048, 2.0))
    var waist := exp(-pow((y - 0.465) / 0.055, 2.0))
    var hip := exp(-pow((y - 0.398) / 0.055, 2.0))
    var thigh := exp(-pow((y - 0.310) / 0.060, 2.0))
    # The imported CC0 shoulder/upper-arm triangles, not the overlaid armor,
    # form the wide horizontal shelf in isolated source-only mobile captures.
    # Pull only the OUTER trapezius/deltoid zone toward the real spine. Keep
    # the central chest, hand tips, face, feet and original four Skin weights.
    # This is a smooth, symmetric rest-space sculpt, not a separate prop.
    var upper_shoulder := exp(-pow((y - 0.738) / 0.052, 2.0))
    var outer_deltoid := smoothstep(0.24, 0.42, side) * (
        1.0 - smoothstep(0.80, 0.98, side))
    var shoulder_taper := upper_shoulder * outer_deltoid
    # The imported CC0 shoulder shelf is almost horizontal in the actual
    # 16:9 front/chase frames. Lower its outer trapezius/deltoid triangles
    # smoothly while keeping the central neck, face, fingers and soles fixed.
    # This reshapes the SAME 65-bone source mesh before jacket/sleeve fitting.
    var shoulder_slope := upper_shoulder * smoothstep(0.26, 0.68, side) * \
        (1.0 - smoothstep(0.87, 0.99, side))
    # Pull the original, still-visible neck/upper trapezius inward as a
    # continuous four-weight surface. Earlier jacket-only collar experiments
    # left a broad violet source-body band exposed beneath the neckline.
    # The mask fades below the shoulders and before the face/head and hands.
    var neckline := exp(-pow((y - 0.815) / 0.032, 2.0)) * \
        smoothstep(0.15, 0.30, side) * (1.0 - smoothstep(0.62, 0.84, side))
    # Athletic silhouette pass: remove inflated hips/thighs and reduce the\n    # broad upper chest, while preserving the continuous imported skin.\n    # The actual 1280x720 source-only images showed an inflated pectoral
    # volume even after all redundant armor shells were retired. Reduce the
    # imported Skin's central chest expansion in X (15% -> 7%) and depth
    # (12% -> 6%), leaving arm/hand/head/foot vertices and Skin binds intact.
    # Original CC0 deltoids are already broad. The previous extra 24% swell
    # created a horizontal inflated shoulder bar even with the collar hidden.
    # Keep the chest athletic while letting the original arm bones read clearly.
    var width_scale := 1.0 + torso * (0.07 * chest + 0.015 * shoulder -
        0.12 * waist + 0.035 * hip) - leg * 0.025 * thigh
    # The original outer shoulder/upper arm now contracts by up to 19% in
    # width and 7.5% in depth, fading before the hands and below the armpit.
    # Existing chest/waist tailoring and all gameplay physics are untouched.
    width_scale -= 0.19 * shoulder_taper + 0.12 * neckline
    var depth_scale := 1.0 + torso * (0.06 * chest + 0.020 * shoulder -
        0.07 * waist + 0.03 * hip) - leg * 0.012 * thigh
    depth_scale -= 0.075 * shoulder_taper + 0.045 * neckline
    var center := bounds.get_center()
    return Vector3(center.x + (point.x - center.x) * width_scale,
        point.y - bounds.size.y * 0.028 * shoulder_slope,
        center.z + (point.z - center.z) * depth_scale)

func _normal(point: Vector3, normal: Vector3, bounds: AABB) -> Vector3:
    var step := maxf(bounds.size.y * 0.0005, 0.0001)
    var dx := (_reshape(point + Vector3(step, 0, 0), bounds) -
        _reshape(point - Vector3(step, 0, 0), bounds)) / (2.0 * step)
    var dy := (_reshape(point + Vector3(0, step, 0), bounds) -
        _reshape(point - Vector3(0, step, 0), bounds)) / (2.0 * step)
    var dz := (_reshape(point + Vector3(0, 0, step), bounds) -
        _reshape(point - Vector3(0, 0, step), bounds)) / (2.0 * step)
    var jacobian := Basis(dx, dy, dz)
    if absf(jacobian.determinant()) < 0.01:
        return normal.normalized()
    return (jacobian.inverse().transposed() * normal).normalized()
