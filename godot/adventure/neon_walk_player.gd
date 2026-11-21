extends CharacterBody3D
## Isolated A1 movement: no runner input actions or shared touch state.
const SPEED := 5.0
const SPRINT_SPEED := 7.5
const JUMP_VELOCITY := 6.5
const GRAVITY := 19.6
const FALL_LIMIT := -12.0
const JUMP_BUFFER_SECONDS := 0.14
const COYOTE_SECONDS := 0.10
var spawn_point := Vector3(0, 1.5, 0)
var move_axis := Vector2.ZERO
var jump_requested := false
var jump_buffer_remaining := 0.0
var coyote_remaining := 0.0
var input_paused := false
var mobile_sprint_held := false
# Visual-only motion layer while the original GLTF is not yet a skinned rig.
# Collision and gameplay velocity remain entirely owned by CharacterBody3D.
var motion_state := "idle"
var motion_clock := 0.0
var motion_landing := 0.0
var motion_was_airborne := false
var motion_visual_home := Vector3.ZERO
var motion_visual_scale := Vector3.ONE
var motion_visual_initialized := false
# Authored Blender AnimationPlayer: actual arms, legs, head and torso move
# with a 16-bone Skin. Controlled by the existing CharacterBody movement
# state; animations are visual-only and never steer collision or score.
var rigged_animation_player: AnimationPlayer
var rigged_animation_name := ""
var rigged_pose_clock := 0.0
var rigged_pose_state := ""
# Preserve the stride phase between walk and sprint to avoid abrupt foot resets.
var rigged_stride_phase := 0.0


func _physics_process(delta: float) -> void:
    # Ignore even a directly invoked physics tick while Safari is backgrounded.
    if input_paused:
        return
    if global_position.y < FALL_LIMIT:
        # Do not apply gravity or stale movement on the same tick as respawn.
        respawn()
        return
    if jump_requested:
        jump_buffer_remaining = JUMP_BUFFER_SECONDS
        jump_requested = false
    # Briefly allow a jump after stepping off an edge, without air double-jumps.
    if is_on_floor():
        coyote_remaining = COYOTE_SECONDS
    else:
        velocity.y -= GRAVITY * delta
    if jump_buffer_remaining > 0.0 and coyote_remaining > 0.0:
        velocity.y = JUMP_VELOCITY
        jump_buffer_remaining = 0.0
        coyote_remaining = 0.0
    else:
        coyote_remaining = maxf(0.0, coyote_remaining - delta)
    jump_buffer_remaining = maxf(0.0, jump_buffer_remaining - delta)
    var keyboard := Vector2(
        float(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT)),
        float(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) - float(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP))
    )
    var axis := (keyboard + move_axis).limit_length(1.0)
    var speed := SPRINT_SPEED if mobile_sprint_held or Input.is_key_pressed(KEY_SHIFT) else SPEED
    velocity.x = axis.x * speed
    velocity.z = axis.y * speed
    move_and_slide()
    # Face the actual travel direction, independently of the runner rig/camera.
    # Rotate visuals only: CharacterBody collision stays axis-independent.
    var visual := get_node_or_null("WalkingVisual") as Node3D
    if visual != null and axis.length_squared() > 0.001:
        visual.rotation.y = lerp_angle(visual.rotation.y, atan2(-axis.x, -axis.y), minf(1.0, delta * 12.0))
    _animate_walking_visual(delta, axis, speed)

func _animate_walking_visual(delta: float, axis: Vector2, speed: float) -> void:
    # Small real-time 3D idle, locomotion, jump and landing transitions. This
    # animates the imported visual, never the physics capsule or camera. It is
    # a polish layer, not a substitute for the future fully rigged walk cycle.
    var visual := get_node_or_null("WalkingVisual") as Node3D
    if visual == null:
        return
    if not motion_visual_initialized:
        motion_visual_home = visual.position
        motion_visual_scale = visual.scale
        motion_visual_initialized = true
    var airborne := not is_on_floor()
    if not airborne and motion_was_airborne:
        motion_landing = 1.0
    motion_was_airborne = airborne
    var moving := axis.length_squared() > 0.015
    var sprinting := moving and speed >= SPRINT_SPEED
    motion_state = "jump" if airborne and velocity.y > 0.1 else "fall" if airborne else "sprint" if sprinting else "walk" if moving else "idle"
    motion_clock += delta * (13.0 if sprinting else 9.0 if moving else 2.0)
    motion_landing = maxf(0.0, motion_landing - delta * 5.0)
    var bob := 0.0
    var tilt := 0.0
    if moving and not airborne:
        bob = absf(sin(motion_clock)) * (0.050 if sprinting else 0.028)
        tilt = sin(motion_clock) * (0.037 if sprinting else 0.021)
    elif airborne:
        bob = 0.018 if velocity.y > 0.0 else -0.015
        tilt = -0.065 if velocity.y > 0.0 else 0.055
    else:
        bob = sin(motion_clock) * 0.010
    # Damped landing squash communicates a grounded impact without changing
    # collision height, even on compact landscape smartphone screens.
    var squash := motion_landing * 0.055
    var target_scale := motion_visual_scale * Vector3(1.0 + squash * 0.4, 1.0 - squash, 1.0 + squash * 0.4)
    var blend := clampf(delta * 13.0, 0.0, 1.0)
    visual.position = visual.position.lerp(motion_visual_home + Vector3(0.0, bob - squash * 0.1, 0.0), blend)
    visual.rotation.z = lerpf(visual.rotation.z, tilt, blend)
    visual.rotation.x = lerpf(visual.rotation.x, -0.07 if sprinting else 0.0, blend)
    visual.scale = visual.scale.lerp(target_scale, blend)
    _animate_rigged_hero(visual, delta)

func _animate_rigged_hero(visual: Node3D, delta: float) -> void:
    if rigged_animation_player == null:
        # Older GLTFs have no animation; keep compatible with the existing
        # original character while using real bones when Blender GLB exists.
        for node in visual.find_children("*", "AnimationPlayer", true, false):
            if node is AnimationPlayer:
                var candidate := node as AnimationPlayer
                for clip_name in candidate.get_animation_list():
                    if clip_name == "RESET":
                        continue
                    var clip := candidate.get_animation(clip_name)
                    if clip != null and clip.length >= 8.0:
                        rigged_animation_player = candidate
                        rigged_animation_name = clip_name
                        rigged_animation_player.play(clip_name)
                        rigged_animation_player.speed_scale = 0.0
                        break
            if rigged_animation_player != null:
                break
    if rigged_animation_player == null:
        return
    var target_state := "land" if motion_landing > 0.25 else motion_state
    if target_state != rigged_pose_state:
        var was_stride := rigged_pose_state == "walk" or rigged_pose_state == "sprint"
        var is_stride := target_state == "walk" or target_state == "sprint"
        rigged_pose_clock = rigged_stride_phase * 2.0 / (1.45 if target_state == "sprint" else 1.12) if was_stride and is_stride else 0.0
        rigged_pose_state = target_state
    rigged_pose_clock += delta
    # Exactly the frame segments exported in make_walk_hero.py (24 FPS):
    # idle 1-49, walk 49-97, sprint 97-145, jump 145-169,
    # fall 169-193, landing 193-217. One GLB Action drives the one Skin.
    var segment_start := 0.0
    var segment_span := 2.0
    var playback_rate := 1.0
    var loop_segment := true
    match target_state:
        "walk":
            segment_start = 2.0
            playback_rate = 1.12
        "sprint":
            segment_start = 4.0
            playback_rate = 1.45
        "jump":
            segment_start = 6.0
            segment_span = 1.0
            loop_segment = false
        "fall":
            segment_start = 7.0
            segment_span = 1.0
            loop_segment = false
        "land":
            segment_start = 8.0
            segment_span = 1.0
            playback_rate = 2.4
            loop_segment = false
    var elapsed := rigged_pose_clock * playback_rate
    var pose_time := fposmod(elapsed, segment_span) if loop_segment else minf(elapsed, segment_span - 0.04)
    if target_state == "walk" or target_state == "sprint":
        rigged_stride_phase = pose_time / segment_span
    var clip := rigged_animation_player.get_animation(rigged_animation_name)
    rigged_animation_player.seek(minf(segment_start + pose_time, clip.length - 0.01), true)


func _unhandled_key_input(event: InputEvent) -> void:
    if input_paused:
        return
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
        jump_requested = true

func set_mobile_move(axis: Vector2) -> void:
    if input_paused:
        return
    move_axis = axis.limit_length(1.0)

func set_mobile_sprint(held: bool) -> void:
    if input_paused:
        return
    mobile_sprint_held = held

func mobile_jump() -> void:
    if input_paused:
        return
    jump_requested = true

func respawn() -> void:
    # Spawn is arena-local; the runner mounts this arena far from world origin.
    global_position = get_parent().to_global(spawn_point)
    velocity = Vector3.ZERO
    move_axis = Vector2.ZERO
    mobile_sprint_held = false
    jump_requested = false
    jump_buffer_remaining = 0.0
    coyote_remaining = 0.0
    # A local retry also restores facing without rotating the collision body.
    var visual := get_node_or_null("WalkingVisual") as Node3D
    if visual != null:
        visual.rotation = Vector3.ZERO
        if motion_visual_initialized:
            visual.position = motion_visual_home
            visual.scale = motion_visual_scale
    motion_state = "idle"
    motion_clock = 0.0
    motion_landing = 0.0
    motion_was_airborne = false
    rigged_pose_clock = 0.0
    rigged_pose_state = "idle"
    rigged_stride_phase = 0.0
    if rigged_animation_player != null:
        rigged_animation_player.seek(0.0, true)

func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
        input_paused = true
        move_axis = Vector2.ZERO
        mobile_sprint_held = false
        jump_requested = false
        jump_buffer_remaining = 0.0
        coyote_remaining = 0.0
    elif what == NOTIFICATION_APPLICATION_FOCUS_IN or what == NOTIFICATION_WM_WINDOW_FOCUS_IN:
        input_paused = false
        move_axis = Vector2.ZERO
        mobile_sprint_held = false
        jump_requested = false
        jump_buffer_remaining = 0.0
        coyote_remaining = 0.0
