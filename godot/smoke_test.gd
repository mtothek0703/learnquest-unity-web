extends SceneTree
## Automated game-level smoke test used by GitHub Actions.
## Runs without a GPU: verifies that the actual level, character, pickups, quiz
## and input actions initialize and can be exercised without script errors.

func _initialize() -> void:
    call_deferred("_run_checks")

func _fail(message: String) -> void:
    push_error("LEARNQUEST TEST FAILED: " + message)
    quit(1)

func _screen_touch(index: int, pressed: bool, position: Vector2) -> InputEventScreenTouch:
    var event := InputEventScreenTouch.new()
    event.index = index
    event.pressed = pressed
    event.position = position
    return event

func _screen_drag(index: int, position: Vector2) -> InputEventScreenDrag:
    var event := InputEventScreenDrag.new()
    event.index = index
    event.position = position
    return event


# Deterministic interpreter checks: timings and finger IDs do not depend on
# the CI runner's frame rate or on an attached phone.
func _check_native_gestures() -> bool:
    var gestures = preload("res://touch_gestures.gd").new()
    gestures.handle(_screen_touch(0, true, Vector2(480, 360)), true, false, 1000, 0, 960.0)
    var event_result: Dictionary = gestures.handle(_screen_drag(0, Vector2(482, 270)), true, false, 1030, 0, 960.0)
    if event_result.get("action", "") != "jump":
        _fail("V52 upward swipe must jump on drag, without waiting for release")
        return false
    event_result = gestures.handle(_screen_touch(0, false, Vector2(482, 255)), true, false, 1060, 0, 960.0)
    if event_result.has("action"):
        _fail("V52 upward swipe jumped twice on finger release")
        return false

    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(480, 300)), true, false, 2000, 0, 960.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(570, 300)), true, false, 2030, 0, 960.0)
    if int(event_result.get("lane", 0)) != 1:
        _fail("V52 drag steering must react immediately")
        return false
    event_result = gestures.handle(_screen_drag(0, Vector2(480, 300)), true, false, 2050, 1, 960.0)
    if int(event_result.get("lane", 9)) != 0:
        _fail("V52 returning a finger to its start must restore its starting lane")
        return false
    event_result = gestures.handle(_screen_touch(0, false, Vector2(480, 300)), true, false, 2070, 0, 960.0)
    if event_result.has("action"):
        _fail("V52 a finished steering drag must not become a double tap")
        return false

    # V67: On wide landscape screens a deliberate 30px sideways start is
    # beyond tap slop, but below the former lane-change lock threshold.
    # Reversing upward must not reinterpret this steering intent as a jump.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(480, 360)), true, false, 2300, 0, 960.0, 360.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(510, 360)), true, false, 2320, 0, 960.0, 360.0)
    if event_result.has("action") or event_result.has("lane"):
        _fail("V67 early sideways intent must not fire an ability or change lane")
        return false
    event_result = gestures.handle(_screen_drag(0, Vector2(510, 220)), true, false, 2340, 0, 960.0, 360.0)
    if event_result.has("action"):
        _fail("V67 sideways-first drag must not turn into an upward jump")
        return false
    event_result = gestures.handle(_screen_touch(0, false, Vector2(510, 220)), true, false, 2360, 0, 960.0, 360.0)
    if event_result.has("action"):
        _fail("V67 sideways-first release must not trigger a jump")
        return false
    # Browsers may skip the final drag frame: release-only paths stay safe.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(480, 360)), true, false, 2400, 0, 960.0, 360.0)
    gestures.handle(_screen_drag(0, Vector2(510, 360)), true, false, 2420, 0, 960.0, 360.0)
    event_result = gestures.handle(_screen_touch(0, false, Vector2(510, 200)), true, false, 2450, 0, 960.0, 360.0)
    if event_result.has("action"):
        _fail("V67 missing final drag frame must not turn steering into jump")
        return false
    # The lock is per touch, not global: a fresh upward swipe still jumps.
    gestures.handle(_screen_touch(0, true, Vector2(480, 360)), true, false, 2500, 0, 960.0, 360.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(480, 270)), true, false, 2520, 0, 960.0, 360.0)
    if event_result.get("action", "") != "jump":
        _fail("V67 fresh deliberate upward swipe must still jump immediately")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(480, 270)), true, false, 2540, 0, 960.0, 360.0)

    # V53: test BOTH real lane boundaries by starting on the left.
    # A moving thumb can wobble near the center-to-right threshold.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(480, 300)), true, false, 2100, -1, 960.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(570, 300)), true, false, 2110, -1, 960.0)
    if int(event_result.get("lane", -9)) != 0:
        _fail("V53 first horizontal drag should enter the adjacent lane")
        return false
    for wobble in [576.0, 578.0, 574.0]:
        event_result = gestures.handle(_screen_drag(0, Vector2(wobble, 300)), true, false, 2120, 0, 960.0)
        if event_result.has("lane"):
            _fail("V53 thumb jitter near the next lane boundary changed lanes")
            return false
    event_result = gestures.handle(_screen_drag(0, Vector2(600, 300)), true, false, 2130, 0, 960.0)
    if int(event_result.get("lane", -9)) != 1:
        _fail("V53 a deliberate wider drag must reach the rightmost lane")
        return false
    event_result = gestures.handle(_screen_drag(0, Vector2(572, 300)), true, false, 2140, 1, 960.0)
    if event_result.has("lane"):
        _fail("V53 small reverse movement must not immediately change lanes")
        return false
    event_result = gestures.handle(_screen_drag(0, Vector2(550, 300)), true, false, 2150, 1, 960.0)
    if int(event_result.get("lane", -9)) != 0:
        _fail("V53 deliberate reverse movement must reach the center lane")
        return false
    event_result = gestures.handle(_screen_drag(0, Vector2(515, 300)), true, false, 2160, 0, 960.0)
    if event_result.has("lane"):
        _fail("V53 small center-line jitter should not snap back")
        return false
    event_result = gestures.handle(_screen_drag(0, Vector2(480, 300)), true, false, 2170, 0, 960.0)
    if int(event_result.get("lane", -9)) != -1:
        _fail("V53 returning to the touch origin must restore the original lane")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(480, 300)), true, false, 2180, -1, 960.0)

    # Mirror the same test on a 320px phone from right to left.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(160, 200)), true, false, 2200, 1, 320.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(115, 200)), true, false, 2210, 1, 320.0)
    if int(event_result.get("lane", 9)) != 0:
        _fail("V53 leftward thumb drag on a narrow phone failed")
        return false
    event_result = gestures.handle(_screen_drag(0, Vector2(111, 200)), true, false, 2220, 0, 320.0)
    if event_result.has("lane"):
        _fail("V53 narrow-phone thumb jitter unexpectedly changed lanes")
        return false
    event_result = gestures.handle(_screen_drag(0, Vector2(90, 200)), true, false, 2230, 0, 320.0)
    if int(event_result.get("lane", 9)) != -1:
        _fail("V53 deliberate leftward drag must reach the leftmost lane")
        return false
    event_result = gestures.handle(_screen_drag(0, Vector2(113, 200)), true, false, 2240, -1, 320.0)
    if event_result.has("lane"):
        _fail("V53 small reverse movement must not oscillate the leftmost lane")
        return false
    event_result = gestures.handle(_screen_drag(0, Vector2(128, 200)), true, false, 2250, -1, 320.0)
    if int(event_result.get("lane", 9)) != 0:
        _fail("V53 deliberate reverse drag must reach center on a phone")
        return false
    event_result = gestures.handle(_screen_drag(0, Vector2(160, 200)), true, false, 2260, 0, 320.0)
    if int(event_result.get("lane", 9)) != 1:
        _fail("V53 returning to touch origin must restore right lane on a phone")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(160, 200)), true, false, 2270, 1, 320.0)

    # Small horizontal/vertical finger drift must not break a double tap.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(480, 300)), true, false, 3000, 0, 960.0)
    gestures.handle(_screen_touch(0, false, Vector2(482, 301)), true, false, 3030, 0, 960.0)
    gestures.handle(_screen_touch(0, true, Vector2(483, 302)), true, false, 3100, 0, 960.0)
    event_result = gestures.handle(_screen_touch(0, false, Vector2(485, 302)), true, false, 3130, 0, 960.0)
    if event_result.get("action", "") != "turbo":
        _fail("V52 double tap with normal finger jitter must activate Turbo")
        return false

    # A scroll/steer between two taps cancels the pending Turbo gesture.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(480, 300)), true, false, 4000, 0, 960.0)
    gestures.handle(_screen_touch(0, false, Vector2(480, 300)), true, false, 4020, 0, 960.0)
    gestures.handle(_screen_touch(0, true, Vector2(480, 300)), true, false, 4080, 0, 960.0)
    gestures.handle(_screen_drag(0, Vector2(560, 300)), true, false, 4110, 0, 960.0)
    gestures.handle(_screen_touch(0, false, Vector2(560, 300)), true, false, 4130, 1, 960.0)
    gestures.handle(_screen_touch(0, true, Vector2(480, 300)), true, false, 4170, 0, 960.0)
    event_result = gestures.handle(_screen_touch(0, false, Vector2(480, 300)), true, false, 4200, 0, 960.0)
    if event_result.has("action"):
        _fail("V52 scrolling between taps accidentally activated Turbo")
        return false

    # V54 regression: a two-finger swipe that returns to its origin is NOT
    # a Shield tap. Prior code checked only final release coordinates.
    for moved_index in [0, 1]:
        gestures.reset()
        gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 4500, 0, 960.0)
        gestures.handle(_screen_touch(1, true, Vector2(460, 300)), true, false, 4530, 0, 960.0)
        var origin := Vector2(400, 300) if moved_index == 0 else Vector2(460, 300)
        gestures.handle(_screen_drag(moved_index, origin + Vector2(100, 0)), true, false, 4550, 0, 960.0)
        gestures.handle(_screen_drag(moved_index, origin), true, false, 4570, 0, 960.0)
        gestures.handle(_screen_touch(0, false, Vector2(400, 300)), true, false, 4590, 0, 960.0)
        event_result = gestures.handle(_screen_touch(1, false, Vector2(460, 300)), true, false, 4600, 0, 960.0)
        if event_result.has("action"):
            _fail("V54 swipe-and-return unexpectedly triggered Shield on finger %d" % moved_index)
            return false
    # Normal two-finger taps still work when neither finger has swiped.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 4700, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 300)), true, false, 4730, 0, 960.0)
    gestures.handle(_screen_touch(0, false, Vector2(400, 300)), true, false, 4760, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(460, 300)), true, false, 4780, 0, 960.0)
    if event_result.get("action", "") != "shield":
        _fail("V54 normal two-finger tap no longer activates Shield")
        return false

    # A finger that starts over the UI suspends all playfield touches.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(150, 200)), true, true, 5000, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, true, Vector2(480, 350)), true, false, 5010, 0, 960.0)
    if event_result.get("captured", false):
        _fail("V52 UI touch must not capture a second playfield finger")
        return false
    event_result = gestures.handle(_screen_drag(1, Vector2(480, 220)), true, false, 5030, 0, 960.0)
    if not event_result.is_empty():
        _fail("V52 blocked secondary finger triggered a gesture")
        return false
    gestures.handle(_screen_touch(1, false, Vector2(480, 220)), true, false, 5040, 0, 960.0)
    gestures.handle(_screen_touch(0, false, Vector2(150, 200)), true, false, 5050, 0, 960.0)

    # Adding a UI finger to an active gesture cancels, not finishes, the jump.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(480, 350)), true, false, 6000, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(150, 200)), true, true, 6010, 0, 960.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(480, 210)), true, false, 6030, 0, 960.0)
    if event_result.has("action"):
        _fail("V52 second finger on UI triggered a playfield action")
        return false
    event_result = gestures.handle(_screen_touch(0, false, Vector2(480, 210)), true, false, 6040, 0, 960.0)
    if event_result.has("action"):
        _fail("V52 releasing a cancelled gesture triggered an action")
        return false
    gestures.handle(_screen_touch(1, false, Vector2(150, 200)), true, false, 6050, 0, 960.0)
    gestures.handle(_screen_touch(0, true, Vector2(480, 350)), true, false, 6100, 0, 960.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(480, 220)), true, false, 6130, 0, 960.0)
    if event_result.get("action", "") != "jump":
        _fail("V52 gesture cancellation did not recover after all fingers lifted")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(480, 220)), true, false, 6150, 0, 960.0)

    # A third finger, including one added after the first finger lifted,
    # must never turn an incomplete multi-touch into a Shield or Attack.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(480, 300)), true, false, 7000, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(580, 300)), true, false, 7020, 0, 960.0)
    gestures.handle(_screen_touch(0, false, Vector2(480, 300)), true, false, 7050, 0, 960.0)
    gestures.handle(_screen_touch(2, true, Vector2(650, 300)), true, false, 7060, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(580, 300)), true, false, 7070, 0, 960.0)
    if event_result.has("action"):
        _fail("V52 third finger activated a power-up")
        return false
    gestures.handle(_screen_touch(2, false, Vector2(650, 300)), true, false, 7080, 0, 960.0)
    gestures.handle(_screen_touch(0, true, Vector2(480, 300)), true, false, 7100, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(580, 300)), true, false, 7120, 0, 960.0)
    gestures.handle(_screen_touch(0, false, Vector2(480, 300)), true, false, 7150, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(580, 300)), true, false, 7170, 0, 960.0)
    if event_result.get("action", "") != "shield":
        _fail("V52 two-finger shield must work again after a cancelled gesture")
        return false

    # Holding two fingers for a long time is not a deliberate power-up.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(480, 300)), true, false, 8000, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(580, 300)), true, false, 8020, 0, 960.0)
    gestures.handle(_screen_touch(0, false, Vector2(480, 300)), true, false, 9000, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(580, 300)), true, false, 9010, 0, 960.0)
    if event_result.has("action"):
        _fail("V52 long two-finger hold accidentally activated an ability")
        return false

    # V55: deliberate two-finger upward movement attacks immediately on the
    # second moving finger, without waiting for either finger to be lifted.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(480, 370)), true, false, 10000, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(580, 370)), true, false, 10020, 0, 960.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(480, 240)), true, false, 10100, 0, 960.0)
    if event_result.has("action"):
        _fail("V55 one moving finger must not activate a two-finger attack")
        return false
    event_result = gestures.handle(_screen_drag(1, Vector2(580, 240)), true, false, 10120, 0, 960.0)
    if event_result.get("action", "") != "attack":
        _fail("V55 second upward drag must activate Super Attack immediately")
        return false
    event_result = gestures.handle(_screen_drag(1, Vector2(580, 210)), true, false, 10140, 0, 960.0)
    if event_result.has("action"):
        _fail("V55 held two-finger attack must not repeat on later drag")
        return false
    event_result = gestures.handle(_screen_touch(0, false, Vector2(480, 220)), true, false, 10200, 0, 960.0)
    if event_result.has("action"):
        _fail("V55 releasing first finger must not repeat Super Attack")
        return false
    event_result = gestures.handle(_screen_touch(1, false, Vector2(580, 210)), true, false, 10220, 0, 960.0)
    if event_result.has("action"):
        _fail("V55 releasing second finger must not repeat Super Attack")
        return false

    # The recognizer must recover after an attack, including two-finger Shield.
    gestures.handle(_screen_touch(0, true, Vector2(480, 300)), true, false, 10300, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(580, 300)), true, false, 10320, 0, 960.0)
    gestures.handle(_screen_touch(0, false, Vector2(480, 300)), true, false, 10350, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(580, 300)), true, false, 10370, 0, 960.0)
    if event_result.get("action", "") != "shield":
        _fail("V55 Shield must recover after an early Super Attack")
        return false

    # If a browser skips ScreenDrag frames, the release-only fallback remains.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(480, 370)), true, false, 10400, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(580, 370)), true, false, 10420, 0, 960.0)
    gestures.handle(_screen_touch(0, false, Vector2(480, 220)), true, false, 10500, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(580, 220)), true, false, 10520, 0, 960.0)
    if event_result.get("action", "") != "attack":
        _fail("V55 missed drag events must still allow release-only Super Attack")
        return false

    # Two-finger sideways scrolling must not become a vertical attack.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(480, 370)), true, false, 10600, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(580, 370)), true, false, 10620, 0, 960.0)
    gestures.handle(_screen_drag(0, Vector2(630, 310)), true, false, 10680, 0, 960.0)
    event_result = gestures.handle(_screen_drag(1, Vector2(730, 310)), true, false, 10700, 0, 960.0)
    if event_result.has("action"):
        _fail("V55 horizontal two-finger scroll must not trigger Super Attack")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(630, 310)), true, false, 10720, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(730, 310)), true, false, 10740, 0, 960.0)
    if event_result.has("action"):
        _fail("V55 horizontal two-finger release must not trigger Super Attack")
        return false
    # V57: sideways-first multi-touch cannot later become Super Attack.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(480, 370)), true, false, 10800, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(580, 370)), true, false, 10820, 0, 960.0)
    gestures.handle(_screen_drag(0, Vector2(600, 370)), true, false, 10840, 0, 960.0)
    gestures.handle(_screen_drag(1, Vector2(700, 370)), true, false, 10860, 0, 960.0)
    gestures.handle(_screen_drag(0, Vector2(480, 220)), true, false, 10880, 0, 960.0)
    event_result = gestures.handle(_screen_drag(1, Vector2(580, 220)), true, false, 10900, 0, 960.0)
    if event_result.has("action"):
        _fail("V57 sideways-first two-finger scroll turned into Super Attack")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(480, 220)), true, false, 10920, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(580, 220)), true, false, 10940, 0, 960.0)
    if event_result.has("action"):
        _fail("V57 sideways-first two-finger release spent attack energy")
        return false
    # A new deliberate upward gesture must still trigger immediately.
    gestures.handle(_screen_touch(0, true, Vector2(480, 370)), true, false, 10960, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(580, 370)), true, false, 10980, 0, 960.0)
    gestures.handle(_screen_drag(0, Vector2(485, 220)), true, false, 11000, 0, 960.0)
    event_result = gestures.handle(_screen_drag(1, Vector2(585, 220)), true, false, 11020, 0, 960.0)
    if event_result.get("action", "") != "attack":
        _fail("V57 direction guard blocked a genuine two-finger Super Attack")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(485, 220)), true, false, 11040, 0, 960.0)
    gestures.handle(_screen_touch(1, false, Vector2(585, 220)), true, false, 11060, 0, 960.0)

    # V58: pinching while moving upward must NOT fire Super Attack.
    # Both fingers travel well beyond the attack threshold but converge.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(480, 370)), true, false, 15000, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(580, 370)), true, false, 15020, 0, 960.0)
    gestures.handle(_screen_drag(0, Vector2(525, 230)), true, false, 15050, 0, 960.0)
    event_result = gestures.handle(_screen_drag(1, Vector2(535, 230)), true, false, 15070, 0, 960.0)
    if event_result.has("action"):
        _fail("V58 upward pinch incorrectly triggered Super Attack during drag")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(525, 230)), true, false, 15100, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(535, 230)), true, false, 15120, 0, 960.0)
    if event_result.has("action"):
        _fail("V58 upward pinch incorrectly triggered Super Attack on release")
        return false

    # A web browser may deliver only the start and end of the pinch.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(480, 370)), true, false, 15200, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(580, 370)), true, false, 15220, 0, 960.0)
    gestures.handle(_screen_touch(0, false, Vector2(525, 230)), true, false, 15280, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(535, 230)), true, false, 15300, 0, 960.0)
    if event_result.has("action"):
        _fail("V58 release-only upward pinch incorrectly triggered Super Attack")
        return false

    # Pinch-then-return must stay blocked for the entire touch sequence.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(480, 370)), true, false, 15400, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(580, 370)), true, false, 15420, 0, 960.0)
    gestures.handle(_screen_drag(0, Vector2(525, 315)), true, false, 15450, 0, 960.0)
    gestures.handle(_screen_drag(1, Vector2(535, 315)), true, false, 15470, 0, 960.0)
    gestures.handle(_screen_drag(0, Vector2(480, 210)), true, false, 15490, 0, 960.0)
    event_result = gestures.handle(_screen_drag(1, Vector2(580, 210)), true, false, 15510, 0, 960.0)
    if event_result.has("action"):
        _fail("V58 pinch-then-return incorrectly activated Super Attack")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(480, 210)), true, false, 15530, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(580, 210)), true, false, 15550, 0, 960.0)
    if event_result.has("action"):
        _fail("V58 pinch-then-return activated Super Attack on release")
        return false

    # Deliberate upward swipe with small lateral drift remains responsive.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(480, 370)), true, false, 15600, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(580, 370)), true, false, 15620, 0, 960.0)
    gestures.handle(_screen_drag(0, Vector2(472, 220)), true, false, 15650, 0, 960.0)
    event_result = gestures.handle(_screen_drag(1, Vector2(588, 220)), true, false, 15670, 0, 960.0)
    if event_result.get("action", "") != "attack":
        _fail("V58 pinch guard blocked a genuine upward Super Attack")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(472, 220)), true, false, 15690, 0, 960.0)
    gestures.handle(_screen_touch(1, false, Vector2(588, 220)), true, false, 15710, 0, 960.0)

    # V56: an OS/browser-cancelled touch is NOT a normal release. It
    # must never complete Turbo, a jump or either two-finger ability.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(480, 300)), true, false, 11000, 0, 960.0)
    gestures.handle(_screen_touch(0, false, Vector2(480, 300)), true, false, 11020, 0, 960.0)
    gestures.handle(_screen_touch(0, true, Vector2(480, 300)), true, false, 11100, 0, 960.0)
    var cancelled_touch := _screen_touch(0, false, Vector2(480, 300))
    cancelled_touch.canceled = true
    event_result = gestures.handle(cancelled_touch, true, false, 11120, 0, 960.0)
    if event_result.has("action"):
        _fail("V56 cancelled tap must not trigger Turbo")
        return false
    gestures.handle(_screen_touch(0, true, Vector2(480, 300)), true, false, 11200, 0, 960.0)
    event_result = gestures.handle(_screen_touch(0, false, Vector2(480, 300)), true, false, 11220, 0, 960.0)
    if event_result.has("action"):
        _fail("V56 cancelled tap must break the double-tap sequence")
        return false

    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(480, 360)), true, false, 12000, 0, 960.0)
    cancelled_touch = _screen_touch(0, false, Vector2(480, 210))
    cancelled_touch.canceled = true
    event_result = gestures.handle(cancelled_touch, true, false, 12060, 0, 960.0)
    if event_result.has("action"):
        _fail("V56 cancelled upward release must not become a jump")
        return false
    gestures.handle(_screen_touch(0, true, Vector2(480, 360)), true, false, 12100, 0, 960.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(480, 260)), true, false, 12130, 0, 960.0)
    if event_result.get("action", "") != "jump":
        _fail("V56 a new swipe must work after touch cancellation")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(480, 260)), true, false, 12160, 0, 960.0)

    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(480, 370)), true, false, 13000, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(580, 370)), true, false, 13020, 0, 960.0)
    cancelled_touch = _screen_touch(0, false, Vector2(480, 220))
    cancelled_touch.canceled = true
    event_result = gestures.handle(cancelled_touch, true, false, 13050, 0, 960.0)
    if event_result.has("action"):
        _fail("V56 cancelled first finger must not fire Super Attack")
        return false
    event_result = gestures.handle(_screen_touch(1, false, Vector2(580, 220)), true, false, 13080, 0, 960.0)
    if event_result.has("action"):
        _fail("V56 remaining finger must not complete a cancelled attack")
        return false
    gestures.handle(_screen_touch(0, true, Vector2(480, 300)), true, false, 13100, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(580, 300)), true, false, 13120, 0, 960.0)
    gestures.handle(_screen_touch(0, false, Vector2(480, 300)), true, false, 13140, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(580, 300)), true, false, 13160, 0, 960.0)
    if event_result.get("action", "") != "shield":
        _fail("V56 normal two-finger Shield must recover after cancellation")
        return false

    # A cancelled UI finger must release its exclusion zone without turning
    # a subsequent playfield touch into a blocked or synthetic gesture.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(150, 200)), true, true, 14000, 0, 960.0)
    cancelled_touch = _screen_touch(0, false, Vector2(150, 200))
    cancelled_touch.canceled = true
    gestures.handle(cancelled_touch, true, false, 14020, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, true, Vector2(480, 360)), true, false, 14040, 0, 960.0)
    if not event_result.get("captured", false):
        _fail("V56 playfield must recover after a cancelled UI touch")
        return false
    event_result = gestures.handle(_screen_drag(1, Vector2(480, 260)), true, false, 14070, 0, 960.0)
    if event_result.get("action", "") != "jump":
        _fail("V56 cancelled UI touch must not poison later playfield input")
        return false
    gestures.handle(_screen_touch(1, false, Vector2(480, 260)), true, false, 14090, 0, 960.0)

    # V60: a landscape phone is short: a deliberate 60px upward thumb swipe
    # must jump immediately, while the same small movement on portrait must
    # not create an accidental jump. Super Attack keeps its safer threshold.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(400, 220)), true, false, 16000, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(402, 160)), true, false, 16030, 0, 800.0, 320.0)
    if event_result.get("action", "") != "jump":
        _fail("V60 landscape upward swipe must jump before release")
        return false
    event_result = gestures.handle(_screen_touch(0, false, Vector2(402, 160)), true, false, 16060, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V60 landscape jump repeated on finger release")
        return false

    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(400, 400)), true, false, 16100, 0, 400.0, 800.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(402, 340)), true, false, 16130, 0, 400.0, 800.0)
    if event_result.has("action"):
        _fail("V60 portrait screen must keep the safer 72px jump threshold")
        return false
    event_result = gestures.handle(_screen_touch(0, false, Vector2(402, 340)), true, false, 16160, 0, 400.0, 800.0)
    if event_result.has("action"):
        _fail("V60 portrait short release incorrectly triggered a jump")
        return false

    # Browsers may omit intermediate drag frames; release-only fallback works.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(400, 220)), true, false, 16200, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_touch(0, false, Vector2(400, 160)), true, false, 16240, 0, 800.0, 320.0)
    if event_result.get("action", "") != "jump":
        _fail("V60 landscape release-only swipe must still jump")
        return false

    # Very short or diagonal drags must not steal taps/scrolling as jumps.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(400, 220)), true, false, 16300, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(402, 175)), true, false, 16330, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V60 landscape 45px drag must not jump")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(402, 175)), true, false, 16360, 0, 800.0, 320.0)
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(400, 220)), true, false, 16400, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(455, 160)), true, false, 16430, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V60 diagonal scrolling must not trigger jump")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(455, 160)), true, false, 16460, 0, 800.0, 320.0)

    # V61: A downward scroll that reverses upward is NOT a jump.
    # The first deliberate direction wins until all fingers are released.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(400, 180)), true, false, 17000, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(400, 225)), true, false, 17020, 0, 800.0, 320.0)
    if event_result.has("action") or event_result.has("lane"):
        _fail("V61 initial downward scroll must not trigger gameplay")
        return false
    event_result = gestures.handle(_screen_drag(0, Vector2(400, 75)), true, false, 17040, 0, 800.0, 320.0)
    if event_result.has("action") or event_result.has("lane"):
        _fail("V61 reversed downward scroll incorrectly jumped or steered")
        return false
    event_result = gestures.handle(_screen_touch(0, false, Vector2(400, 75)), true, false, 17060, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V61 releasing reversed downward scroll incorrectly jumped")
        return false
    gestures.handle(_screen_touch(0, true, Vector2(400, 180)), true, false, 17100, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(400, 110)), true, false, 17120, 0, 800.0, 320.0)
    if event_result.get("action", "") != "jump":
        _fail("V61 new deliberate upward swipe must still jump immediately")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(400, 110)), true, false, 17140, 0, 800.0, 320.0)

    # Two-finger downward scroll, then reversal, must never activate Attack.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(360, 260)), true, false, 17200, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 260)), true, false, 17220, 0, 800.0, 320.0)
    gestures.handle(_screen_drag(0, Vector2(360, 320)), true, false, 17240, 0, 800.0, 320.0)
    gestures.handle(_screen_drag(1, Vector2(460, 320)), true, false, 17260, 0, 800.0, 320.0)
    gestures.handle(_screen_drag(0, Vector2(360, 100)), true, false, 17280, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_drag(1, Vector2(460, 100)), true, false, 17300, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V61 reversing a two-finger downward scroll triggered Attack")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(360, 100)), true, false, 17320, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(460, 100)), true, false, 17340, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V61 releasing a reversed two-finger scroll triggered Attack")
        return false
    gestures.handle(_screen_touch(0, true, Vector2(360, 260)), true, false, 17400, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 260)), true, false, 17420, 0, 800.0, 320.0)
    gestures.handle(_screen_drag(0, Vector2(360, 110)), true, false, 17440, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_drag(1, Vector2(460, 110)), true, false, 17460, 0, 800.0, 320.0)
    if event_result.get("action", "") != "attack":
        _fail("V61 a fresh two-finger upward swipe must still Attack")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(360, 110)), true, false, 17480, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, false, Vector2(460, 110)), true, false, 17500, 0, 800.0, 320.0)

    # V62: A second finger added after a long one-finger hold is NOT a
    # deliberate simultaneous gesture. It must not spend attack energy.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(360, 260)), true, false, 18000, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 260)), true, false, 18500, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(360, 110)), true, false, 18530, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V62 late second finger incorrectly activated an ability on first drag")
        return false
    event_result = gestures.handle(_screen_drag(1, Vector2(460, 110)), true, false, 18560, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V62 late second finger incorrectly triggered Super Attack")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(360, 110)), true, false, 18580, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(460, 110)), true, false, 18600, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V62 late second finger triggered an attack on release")
        return false

    # The same delayed hold must not be interpreted as a two-finger Shield.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(360, 260)), true, false, 18700, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 260)), true, false, 19150, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(0, false, Vector2(360, 260)), true, false, 19170, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(460, 260)), true, false, 19190, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V62 delayed second finger incorrectly triggered Shield")
        return false

    # A fresh, near-simultaneous two-finger swipe still attacks immediately.
    gestures.handle(_screen_touch(0, true, Vector2(360, 260)), true, false, 19250, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 260)), true, false, 19290, 0, 800.0, 320.0)
    gestures.handle(_screen_drag(0, Vector2(360, 110)), true, false, 19320, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_drag(1, Vector2(460, 110)), true, false, 19350, 0, 800.0, 320.0)
    if event_result.get("action", "") != "attack":
        _fail("V62 fresh two-finger swipe must still activate Super Attack")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(360, 110)), true, false, 19370, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, false, Vector2(460, 110)), true, false, 19390, 0, 800.0, 320.0)

    # V65: very close fingers can be a pinch on a phone. Their shared upward
    # movement must not trigger Super Attack, either during drag or on release.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 20000, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(424, 300)), true, false, 20020, 0, 960.0)
    gestures.handle(_screen_drag(0, Vector2(400, 160)), true, false, 20050, 0, 960.0)
    event_result = gestures.handle(_screen_drag(1, Vector2(424, 160)), true, false, 20070, 0, 960.0)
    if event_result.has("action"):
        _fail("V65 close-start two-finger upward drag spent attack energy")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(400, 160)), true, false, 20100, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(424, 160)), true, false, 20120, 0, 960.0)
    if event_result.has("action"):
        _fail("V65 close-start gesture attacked after release")
        return false

    # Some browsers omit drag frames. The release-only fallback needs the same guard.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 20200, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(420, 300)), true, false, 20220, 0, 960.0)
    gestures.handle(_screen_touch(0, false, Vector2(400, 150)), true, false, 20280, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(420, 150)), true, false, 20300, 0, 960.0)
    if event_result.has("action"):
        _fail("V65 release-only close-start gesture spent attack energy")
        return false

    # A close two-finger TAP remains a valid shield gesture.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 20400, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(420, 300)), true, false, 20420, 0, 960.0)
    gestures.handle(_screen_touch(0, false, Vector2(400, 300)), true, false, 20460, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(420, 300)), true, false, 20480, 0, 960.0)
    if event_result.get("action", "") != "shield":
        _fail("V65 close-start shield tap should remain accessible")
        return false

    # A deliberate spaced upward swipe still attacks immediately.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 20500, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(480, 300)), true, false, 20520, 0, 960.0)
    gestures.handle(_screen_drag(0, Vector2(400, 150)), true, false, 20550, 0, 960.0)
    event_result = gestures.handle(_screen_drag(1, Vector2(480, 150)), true, false, 20570, 0, 960.0)
    if event_result.get("action", "") != "attack":
        _fail("V65 spaced two-finger upward swipe must still attack on drag")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(400, 150)), true, false, 20600, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(480, 150)), true, false, 20620, 0, 960.0)
    if event_result.has("action"):
        _fail("V65 spaced swipe must not attack again on release")
        return false

    # V68 regression: a 30px sideways-first two-finger gesture is scrolling,
    # not an upward Super Attack. Previously the 48px intent lock missed it,
    # and the later upward motion could consume energy on a real phone.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(360, 300)), true, false, 20700, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 300)), true, false, 20720, 0, 960.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(390, 300)), true, false, 20740, 0, 960.0)
    if event_result.has("action"):
        _fail("V68 initial sideways scroll unexpectedly triggered an ability")
        return false
    gestures.handle(_screen_drag(0, Vector2(390, 140)), true, false, 20760, 0, 960.0)
    event_result = gestures.handle(_screen_drag(1, Vector2(460, 140)), true, false, 20780, 0, 960.0)
    if event_result.has("action"):
        _fail("V68 sideways-first two-finger scroll became a Super Attack")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(390, 140)), true, false, 20800, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(460, 140)), true, false, 20820, 0, 960.0)
    if event_result.has("action"):
        _fail("V68 sideways-first scroll attacked on finger release")
        return false
    # If Safari skips the final drag frames, the release-only fallback
    # must respect the earlier sideways-intent lock too.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(360, 300)), true, false, 20830, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 300)), true, false, 20840, 0, 960.0)
    gestures.handle(_screen_drag(0, Vector2(390, 300)), true, false, 20850, 0, 960.0)
    gestures.handle(_screen_touch(0, false, Vector2(390, 140)), true, false, 20860, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(460, 140)), true, false, 20870, 0, 960.0)
    if event_result.has("action"):
        _fail("V68 release-only sideways-first scroll spent attack energy")
        return false
    # The block belongs only to that touch sequence; a fresh intentional
    # two-finger upward swipe must still fire before release.
    gestures.handle(_screen_touch(0, true, Vector2(360, 300)), true, false, 20900, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 300)), true, false, 20920, 0, 960.0)
    gestures.handle(_screen_drag(0, Vector2(360, 140)), true, false, 20940, 0, 960.0)
    event_result = gestures.handle(_screen_drag(1, Vector2(460, 140)), true, false, 20960, 0, 960.0)
    if event_result.get("action", "") != "attack":
        _fail("V68 fresh deliberate two-finger swipe must still attack immediately")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(360, 140)), true, false, 20980, 0, 960.0)
    gestures.handle(_screen_touch(1, false, Vector2(460, 140)), true, false, 21000, 0, 960.0)

    # V70 regression: 30px is deliberate downward scrolling, not jitter.
    # A short downward-first drag must never turn into a jump after reversal.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(400, 180)), true, false, 22000, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(400, 210)), true, false, 22020, 0, 800.0, 320.0)
    if event_result.has("action") or event_result.has("lane"):
        _fail("V70 short downward-first drag must remain inert")
        return false
    event_result = gestures.handle(_screen_drag(0, Vector2(400, 85)), true, false, 22040, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V70 short downward-first reversal incorrectly jumped")
        return false
    event_result = gestures.handle(_screen_touch(0, false, Vector2(400, 85)), true, false, 22060, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V70 releasing a short downward-first reversal incorrectly jumped")
        return false
    # The same regression applies to two-finger scrolling and Super Attack.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(360, 260)), true, false, 22100, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 260)), true, false, 22120, 0, 800.0, 320.0)
    gestures.handle(_screen_drag(0, Vector2(360, 290)), true, false, 22140, 0, 800.0, 320.0)
    gestures.handle(_screen_drag(1, Vector2(460, 290)), true, false, 22160, 0, 800.0, 320.0)
    gestures.handle(_screen_drag(0, Vector2(360, 100)), true, false, 22180, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_drag(1, Vector2(460, 100)), true, false, 22200, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V70 short two-finger downward-first reversal spent attack energy")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(360, 100)), true, false, 22220, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(460, 100)), true, false, 22240, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V70 two-finger reversal spent attack energy on release")
        return false
    # Guard resets after release: fresh intentional swipes must stay immediate.
    gestures.handle(_screen_touch(0, true, Vector2(400, 180)), true, false, 22300, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(400, 100)), true, false, 22320, 0, 800.0, 320.0)
    if event_result.get("action", "") != "jump":
        _fail("V70 early scroll guard blocked a new deliberate jump")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(400, 100)), true, false, 22340, 0, 800.0, 320.0)

    # V74 regression: a diagonal downward-first thumb drag is a scroll,
    # even if it is not 1.2x vertically dominant. Reversing it must not
    # unexpectedly jump or spend Super Attack energy.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(400, 220)), true, false, 39000, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(432, 250)), true, false, 39020, 0, 800.0, 320.0)
    if event_result.has("action") or event_result.has("lane"):
        _fail("V74 initial diagonal downward scroll must be inert")
        return false
    event_result = gestures.handle(_screen_drag(0, Vector2(400, 100)), true, false, 39040, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V74 diagonal downward-first reversal must not jump")
        return false
    event_result = gestures.handle(_screen_touch(0, false, Vector2(400, 100)), true, false, 39060, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V74 diagonal scroll release must not jump")
        return false

    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(360, 260)), true, false, 40000, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 260)), true, false, 40020, 0, 800.0, 320.0)
    gestures.handle(_screen_drag(0, Vector2(392, 290)), true, false, 40040, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_drag(1, Vector2(492, 290)), true, false, 40060, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V74 diagonal two-finger scroll must not activate a power-up")
        return false
    gestures.handle(_screen_drag(0, Vector2(360, 140)), true, false, 40080, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_drag(1, Vector2(460, 140)), true, false, 40100, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V74 diagonal two-finger scroll reversal must not attack")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(360, 140)), true, false, 40120, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(460, 140)), true, false, 40140, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V74 diagonal two-finger release must not attack")
        return false
    # The lock is per gesture; fresh intentional upward swipes still work.
    gestures.handle(_screen_touch(0, true, Vector2(400, 260)), true, false, 40200, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(400, 170)), true, false, 40220, 0, 800.0, 320.0)
    if event_result.get("action", "") != "jump":
        _fail("V74 fresh upward swipe must still jump immediately")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(400, 170)), true, false, 40240, 0, 800.0, 320.0)

    # A new, intentional two-finger upward swipe still attacks immediately.
    gestures.handle(_screen_touch(0, true, Vector2(360, 260)), true, false, 41000, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 260)), true, false, 41020, 0, 800.0, 320.0)
    gestures.handle(_screen_drag(0, Vector2(360, 150)), true, false, 41040, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_drag(1, Vector2(460, 150)), true, false, 41060, 0, 800.0, 320.0)
    if event_result.get("action", "") != "attack":
        _fail("V74 a fresh deliberate two-finger upward swipe must still attack")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(360, 150)), true, false, 41080, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, false, Vector2(460, 150)), true, false, 41100, 0, 800.0, 320.0)

    # V71: A shield TAP is timed from the first finger down. Previously a
    # 520ms first-finger hold could still trigger Shield because the 420ms
    # timer started only when the second finger joined 170ms later.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(360, 260)), true, false, 23000, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 260)), true, false, 23170, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(0, false, Vector2(360, 260)), true, false, 23500, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(460, 260)), true, false, 23520, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V71 prolonged first-finger hold must not spend Shield energy")
        return false
    # The rejected long hold must not poison the next intentional quick tap.
    gestures.handle(_screen_touch(0, true, Vector2(360, 260)), true, false, 23600, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 260)), true, false, 23650, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(0, false, Vector2(360, 260)), true, false, 23830, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(460, 260)), true, false, 23860, 0, 800.0, 320.0)
    if event_result.get("action", "") != "shield":
        _fail("V71 quick two-finger tap must still activate Shield")
        return false
    # Exact boundary is valid; a single millisecond longer is a hold.
    gestures.handle(_screen_touch(0, true, Vector2(360, 260)), true, false, 24000, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 260)), true, false, 24160, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(0, false, Vector2(360, 260)), true, false, 24400, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(460, 260)), true, false, 24420, 0, 800.0, 320.0)
    if event_result.get("action", "") != "shield":
        _fail("V71 420ms two-finger tap must remain valid")
        return false
    gestures.handle(_screen_touch(0, true, Vector2(360, 260)), true, false, 25000, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 260)), true, false, 25160, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(0, false, Vector2(360, 260)), true, false, 25400, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(460, 260)), true, false, 25421, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V71 421ms first-finger hold must not trigger Shield")
        return false

    # V72 regression: the attack deadline must include the FIRST finger's
    # hold, not only time since the second finger arrived. Otherwise a long
    # two-finger hold can spend Super Attack energy after 900ms overall.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(360, 300)), true, false, 30000, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 300)), true, false, 30150, 0, 800.0, 320.0)
    gestures.handle(_screen_drag(0, Vector2(360, 150)), true, false, 30920, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_drag(1, Vector2(460, 150)), true, false, 30940, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V72 expired first-finger hold triggered Super Attack on drag")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(360, 150)), true, false, 30960, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(460, 150)), true, false, 30980, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V72 expired two-finger hold triggered attack on release")
        return false

    # Browser may omit drag frames; release-only recognition has the same
    # deadline, even if the second finger was pressed 150ms later.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(360, 300)), true, false, 31000, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 300)), true, false, 31150, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(0, false, Vector2(360, 150)), true, false, 31920, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(460, 150)), true, false, 31940, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V72 release-only long hold incorrectly triggered Super Attack")
        return false

    # The 900ms boundary remains valid and a 901ms gesture is rejected.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(360, 300)), true, false, 32000, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 300)), true, false, 32150, 0, 800.0, 320.0)
    gestures.handle(_screen_drag(0, Vector2(360, 150)), true, false, 32880, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_drag(1, Vector2(460, 150)), true, false, 32900, 0, 800.0, 320.0)
    if event_result.get("action", "") != "attack":
        _fail("V72 deliberate 900ms two-finger attack must still work")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(360, 150)), true, false, 32920, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, false, Vector2(460, 150)), true, false, 32940, 0, 800.0, 320.0)

    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(360, 300)), true, false, 33000, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 300)), true, false, 33150, 0, 800.0, 320.0)
    gestures.handle(_screen_drag(0, Vector2(360, 150)), true, false, 33880, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_drag(1, Vector2(460, 150)), true, false, 33901, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V72 901ms first-finger hold must not activate attack")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(360, 150)), true, false, 33920, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, false, Vector2(460, 150)), true, false, 33940, 0, 800.0, 320.0)

    # The timeout must not poison the next quick intentional gesture.
    gestures.handle(_screen_touch(0, true, Vector2(360, 300)), true, false, 34000, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 300)), true, false, 34020, 0, 800.0, 320.0)
    gestures.handle(_screen_drag(0, Vector2(360, 150)), true, false, 34070, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_drag(1, Vector2(460, 150)), true, false, 34090, 0, 800.0, 320.0)
    if event_result.get("action", "") != "attack":
        _fail("V72 a new quick two-finger swipe must attack immediately")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(360, 150)), true, false, 34110, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, false, Vector2(460, 150)), true, false, 34130, 0, 800.0, 320.0)

    # V73 regression: an attack must be one coordinated two-finger swipe,
    # not two upward strokes completed hundreds of milliseconds apart.
    # WebKit may skip drag frames, so check release-only events as well.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(360, 300)), true, false, 35000, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 300)), true, false, 35020, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(0, false, Vector2(360, 150)), true, false, 35100, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(460, 150)), true, false, 35320, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V73 staggered finger releases spent Super Attack energy")
        return false

    # Keep release-only fallback for near-simultaneous two-finger swipes.
    gestures.handle(_screen_touch(0, true, Vector2(360, 300)), true, false, 36000, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 300)), true, false, 36020, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(0, false, Vector2(360, 150)), true, false, 36100, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(460, 150)), true, false, 36280, 0, 800.0, 320.0)
    if event_result.get("action", "") != "attack":
        _fail("V73 180ms two-finger release gap must preserve deliberate attack")
        return false

    # Just beyond the boundary is sequential, not a simultaneous attack.
    gestures.handle(_screen_touch(0, true, Vector2(360, 300)), true, false, 37000, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 300)), true, false, 37020, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(0, false, Vector2(360, 150)), true, false, 37100, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(460, 150)), true, false, 37281, 0, 800.0, 320.0)
    if event_result.has("action"):
        _fail("V73 181ms release gap must not activate attack")
        return false

    # The rejected attempt must not block a new quick gesture.
    gestures.handle(_screen_touch(0, true, Vector2(360, 300)), true, false, 38000, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(1, true, Vector2(460, 300)), true, false, 38020, 0, 800.0, 320.0)
    gestures.handle(_screen_touch(0, false, Vector2(360, 150)), true, false, 38100, 0, 800.0, 320.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(460, 150)), true, false, 38120, 0, 800.0, 320.0)
    if event_result.get("action", "") != "attack":
        _fail("V73 quick two-finger attack did not recover")
        return false

    if not gestures.handle(InputEventMouseMotion.new(), true, false, 10300, 0, 960.0).is_empty():
        _fail("V52 synthetic mouse movement must not become a touch gesture")
        return false
    gestures.handle(_screen_touch(0, true, Vector2(480, 350)), true, false, 10400, 0, 960.0)
    gestures.handle(_screen_drag(0, Vector2(480, 220)), false, false, 10430, 0, 960.0)
    if not gestures.handle(_screen_touch(0, false, Vector2(480, 220)), true, false, 10450, 0, 960.0).is_empty():
        _fail("V52 disabled gestures must discard in-flight fingers")
        return false
    # V76: Safari can drop the release when the browser loses focus, then
    # recycle pointer index 0 on the next real press. Without recovery the
    # controls stay locked until a release event that will never arrive.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 60000, 0, 960.0)
    gestures.invalidate_focus(60010)
    event_result = gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 60609, 0, 960.0)
    if not event_result.is_empty():
        _fail("V76 focus quarantine must reject recycled presses before 600 ms")
        return false
    event_result = gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 60610, 0, 960.0)
    if not bool(event_result.get("captured", false)):
        _fail("V76 recycled pointer index must recover after focus grace period")
        return false
    event_result = gestures.handle(_screen_drag(0, Vector2(400, 190)), true, false, 60640, 0, 960.0)
    if event_result.get("action", "") != "jump":
        _fail("V76 recovered pointer must immediately respond to a fresh swipe")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(400, 190)), true, false, 60660, 0, 960.0)

    # Another pointer cannot bypass a quarantined finger even after 600 ms.
    # A recycled index may recover only when it is the sole blocked pointer.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 70000, 0, 960.0)
    gestures.invalidate_focus(70010)
    event_result = gestures.handle(_screen_touch(1, true, Vector2(500, 300)), true, false, 70700, 0, 960.0)
    if not event_result.is_empty():
        _fail("V76 a different second finger must remain blocked after focus loss")
        return false
    event_result = gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 70710, 0, 960.0)
    if not event_result.is_empty():
        _fail("V76 focus recovery must wait while a second pointer is quarantined")
        return false
    gestures.handle(_screen_touch(1, false, Vector2(500, 300)), true, false, 70720, 0, 960.0)
    event_result = gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 70730, 0, 960.0)
    if not bool(event_result.get("captured", false)):
        _fail("V76 sole recycled pointer must recover after other pointers lift")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(400, 300)), true, false, 70750, 0, 960.0)

    # Rotation/layout invalidation has no focus grace exception: a still-held
    # finger must remain blocked until its actual release.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 80000, 0, 960.0)
    gestures.invalidate_layout()
    event_result = gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 82000, 0, 960.0)
    if not event_result.is_empty():
        _fail("V76 layout quarantine must not unlock on a duplicate press")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(400, 300)), true, false, 82020, 0, 960.0)
    event_result = gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 82040, 0, 960.0)
    if not bool(event_result.get("captured", false)):
        _fail("V76 layout quarantine must recover after actual release")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(400, 300)), true, false, 82060, 0, 960.0)

    # V77: Safari may skip ScreenDrag and report only a very late release.
    # A finger held on the playfield for >900ms is not an intentional jump.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 90000, 0, 960.0)
    event_result = gestures.handle(_screen_touch(0, false, Vector2(400, 180)), true, false, 90901, 0, 960.0)
    if event_result.has("action"):
        _fail("V77 long-held finger released upward must not trigger a jump")
        return false
    # The 900ms boundary still allows an intentional swipe if drag was lost.
    gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 91000, 0, 960.0)
    event_result = gestures.handle(_screen_touch(0, false, Vector2(400, 180)), true, false, 91900, 0, 960.0)
    if event_result.get("action", "") != "jump":
        _fail("V77 release-only swipe at 900ms must remain available")
        return false
    # Long holds must not disable the immediate, drag-driven jump on next touch.
    gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 92000, 0, 960.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(400, 180)), true, false, 92030, 0, 960.0)
    if event_result.get("action", "") != "jump":
        _fail("V77 fresh upward drag must still jump immediately")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(400, 180)), true, false, 92060, 0, 960.0)

    # V78: some browser interruptions reuse an index without delivering the
    # previous release or focus callback. A second press of an already-active
    # index must invalidate the stale gesture origin, never jump/steer/attack.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 100000, 0, 960.0)
    gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 100030, 0, 960.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(400, 180)), true, false, 100060, 0, 960.0)
    if event_result.has("action") or event_result.has("lane"):
        _fail("V78 duplicate pointer press must quarantine stale single-finger movement")
        return false
    event_result = gestures.handle(_screen_touch(0, false, Vector2(400, 180)), true, false, 100080, 0, 960.0)
    if event_result.has("action") or event_result.has("lane"):
        _fail("V78 stale pointer release must not activate jump, turbo or steering")
        return false
    gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 100100, 0, 960.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(400, 180)), true, false, 100130, 0, 960.0)
    if event_result.get("action", "") != "jump":
        _fail("V78 fresh touch after duplicate-index quarantine must jump immediately")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(400, 180)), true, false, 100150, 0, 960.0)

    # Duplicate press during multi-touch must also quarantine BOTH fingers:
    # the remaining finger must not turn into a shield or Super Attack.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(400, 360)), true, false, 101000, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(500, 360)), true, false, 101020, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(500, 360)), true, false, 101040, 0, 960.0)
    event_result = gestures.handle(_screen_drag(0, Vector2(400, 220)), true, false, 101060, 0, 960.0)
    if event_result.has("action") or event_result.has("lane"):
        _fail("V78 duplicated multi-touch pointer must quarantine first finger")
        return false
    event_result = gestures.handle(_screen_drag(1, Vector2(500, 220)), true, false, 101080, 0, 960.0)
    if event_result.has("action") or event_result.has("lane"):
        _fail("V78 duplicated multi-touch pointer must not trigger Super Attack")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(400, 220)), true, false, 101100, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(500, 220)), true, false, 101120, 0, 960.0)
    if event_result.has("action"):
        _fail("V78 duplicate multi-touch release must not spend ability energy")
        return false
    gestures.handle(_screen_touch(0, true, Vector2(400, 360)), true, false, 101200, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(500, 360)), true, false, 101220, 0, 960.0)
    gestures.handle(_screen_drag(0, Vector2(400, 220)), true, false, 101240, 0, 960.0)
    event_result = gestures.handle(_screen_drag(1, Vector2(500, 220)), true, false, 101260, 0, 960.0)
    if event_result.get("action", "") != "attack":
        _fail("V78 fresh two-finger attack must work after quarantine is cleared")
        return false
    gestures.handle(_screen_touch(0, false, Vector2(400, 220)), true, false, 101280, 0, 960.0)
    gestures.handle(_screen_touch(1, false, Vector2(500, 220)), true, false, 101300, 0, 960.0)
    # V79 regression: two fingers released far apart are NOT a coordinated
    # Shield tap, even if the second finger lifts before the 420ms timeout.
    # This used to spend shield energy on a normal staggered two-finger hold.
    gestures.reset()
    gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 110000, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(500, 300)), true, false, 110020, 0, 960.0)
    event_result = gestures.handle(_screen_touch(0, false, Vector2(400, 300)), true, false, 110060, 0, 960.0)
    if event_result.has("action"):
        _fail("V79 first release must not activate Shield")
        return false
    event_result = gestures.handle(_screen_touch(1, false, Vector2(500, 300)), true, false, 110241, 0, 960.0)
    if event_result.has("action"):
        _fail("V79 shield must reject a 181ms gap between finger releases")
        return false
    # A deliberately coordinated release at the 180ms boundary still works.
    gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 111000, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(500, 300)), true, false, 111020, 0, 960.0)
    gestures.handle(_screen_touch(0, false, Vector2(400, 300)), true, false, 111060, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(500, 300)), true, false, 111240, 0, 960.0)
    if event_result.get("action", "") != "shield":
        _fail("V79 shield must accept a coordinated 180ms release gap")
        return false
    # After a rejected hold, a new ordinary quick two-finger tap must work.
    gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 112000, 0, 960.0)
    gestures.handle(_screen_touch(1, true, Vector2(500, 300)), true, false, 112020, 0, 960.0)
    gestures.handle(_screen_touch(0, false, Vector2(400, 300)), true, false, 112050, 0, 960.0)
    event_result = gestures.handle(_screen_touch(1, false, Vector2(500, 300)), true, false, 112080, 0, 960.0)
    if event_result.get("action", "") != "shield":
        _fail("V79 fresh quick shield tap must still work after a rejected hold")
        return false
    return true

func _run_checks() -> void:
    if not _check_native_gestures():
        return
    var scene := load("res://main.tscn") as PackedScene
    if scene == null:
        _fail("Unable to load main.tscn")
        return
    var game := scene.instantiate() as Node3D
    if game == null:
        _fail("Main scene is not a Node3D")
        return
    root.add_child(game)
    await process_frame
    # V66: a browser tab switch / incoming call can suppress touch-cancel
    # events. Focus loss must invalidate held fingers and pending Turbo taps.
    var focus_gestures = game.get("touch_steering")
    focus_gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 1000, 0, 960.0)
    game.notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
    var focus_result: Dictionary = focus_gestures.handle(_screen_drag(0, Vector2(400, 180)), true, false, 1040, 0, 960.0)
    if not focus_result.is_empty():
        _fail("V66 resumed drag after window focus loss triggered an old gesture")
        return
    focus_result = focus_gestures.handle(_screen_touch(0, false, Vector2(400, 180)), true, false, 1060, 0, 960.0)
    if not focus_result.is_empty():
        _fail("V66 stale finger release after focus loss was not ignored")
        return
    focus_gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 1100, 0, 960.0)
    focus_gestures.handle(_screen_touch(1, true, Vector2(480, 300)), true, false, 1120, 0, 960.0)
    game.notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
    focus_result = focus_gestures.handle(_screen_touch(0, false, Vector2(400, 170)), true, false, 1150, 0, 960.0)
    if not focus_result.is_empty():
        _fail("V66 application focus loss must cancel two-finger abilities")
        return
    focus_result = focus_gestures.handle(_screen_touch(1, false, Vector2(480, 170)), true, false, 1170, 0, 960.0)
    if not focus_result.is_empty():
        _fail("V66 second stale finger must not fire Super Attack")
        return
    focus_gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 1200, 0, 960.0)
    focus_result = focus_gestures.handle(_screen_drag(0, Vector2(400, 180)), true, false, 1230, 0, 960.0)
    if focus_result.get("action", "") != "jump":
        _fail("V66 fresh gestures must work immediately after focus resumes")
        return
    focus_gestures.handle(_screen_touch(0, false, Vector2(400, 180)), true, false, 1260, 0, 960.0)
    # V75 regression: if the browser loses focus while finger 0 is still
    # physically down, a second finger must not become a new game gesture.
    # A simple reset() forgets the held pointer and wrongly accepts finger 1.
    focus_gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 1300, 0, 960.0)
    game.notification(Node.NOTIFICATION_WM_WINDOW_FOCUS_OUT)
    focus_result = focus_gestures.handle(_screen_touch(1, true, Vector2(480, 300)), true, false, 1320, 0, 960.0)
    if not focus_result.is_empty():
        _fail("V75 second finger after focus loss must not start a new gesture while first is held")
        return
    focus_result = focus_gestures.handle(_screen_drag(1, Vector2(480, 180)), true, false, 1350, 0, 960.0)
    if not focus_result.is_empty():
        _fail("V75 second finger drag after focus loss must remain quarantined")
        return
    focus_result = focus_gestures.handle(_screen_touch(0, false, Vector2(400, 300)), true, false, 1370, 0, 960.0)
    if not focus_result.is_empty():
        _fail("V75 old finger release must not activate an ability")
        return
    focus_result = focus_gestures.handle(_screen_touch(1, false, Vector2(480, 180)), true, false, 1390, 0, 960.0)
    if not focus_result.is_empty():
        _fail("V75 quarantined second finger release must not activate an ability")
        return
    focus_result = focus_gestures.handle(_screen_touch(0, true, Vector2(400, 300)), true, false, 1420, 0, 960.0)
    if not bool(focus_result.get("captured", false)):
        _fail("V75 fresh gesture must recover after all held fingers release")
        return
    focus_result = focus_gestures.handle(_screen_drag(0, Vector2(400, 180)), true, false, 1450, 0, 960.0)
    if focus_result.get("action", "") != "jump":
        _fail("V75 fresh upward swipe must jump immediately after focus recovery")
        return
    focus_gestures.handle(_screen_touch(0, false, Vector2(400, 180)), true, false, 1470, 0, 960.0)
    if game.get_node_or_null("LearnQuest Skyway world") == null:
        _fail("Skyway 3D environment is missing")
        return
    # V80: the landscape-first version has substantial foreground 3D depth.
    var cinematic := game.get_node_or_null("LearnQuest Skyway world/Cinematic skybridges") as Node3D
    if cinematic == null or cinematic.get_child_count() != 3:
        _fail("Three cinematic 3D skybridges are missing from Neon City")
        return
    var first_bridge := cinematic.get_node_or_null("Cinematic Skybridge 0") as Node3D
    var cinematic_arch := first_bridge.get_node_or_null("Sculpted Luminous Arch 0") as MeshInstance3D if first_bridge != null else null
    var floating_sign := first_bridge.get_node_or_null("Floating Holographic Road Sign") as Node3D if first_bridge != null else null
    if cinematic_arch == null or not (cinematic_arch.mesh is ArrayMesh) or (cinematic_arch.mesh as ArrayMesh).surface_get_array_len(0) < 1500:
        _fail("Sculpted luminous landscape bridge requires real curved mesh geometry")
        return
    if floating_sign == null or floating_sign.get_node_or_null("Translucent Hologram") == null:
        _fail("The animated floating city hologram is missing")
        return
    var bridge_z := first_bridge.position.z
    cinematic.set("running", true)
    cinematic.call("_process", 0.1)
    if first_bridge.position.z <= bridge_z:
        _fail("Cinematic skybridges do not scroll with the race")
        return
    cinematic.set("running", false)
    # V89: giant shaded searchlight towers and translucent sweeping 3D shafts
    # must frame the landscape without covering the rider or changing physics.
    var searchlights := game.get_node_or_null("LearnQuest Skyway world/Cinematic neon searchlights") as Node3D
    if searchlights == null or searchlights.get_child_count() != 3:
        _fail("V89 Neon City needs three cinematic 3D searchlight towers")
        return
    var searchlight_tower := searchlights.get_node_or_null("Neon searchlight tower 0") as Node3D
    var scanner := searchlight_tower.get_node_or_null("Sweeping twin holographic spotlights") as Node3D if searchlight_tower != null else null
    var searchlight_beam := scanner.get_node_or_null("Left volumetric light shaft") as MeshInstance3D if scanner != null else null
    var beacon := scanner.get_node_or_null("Animated cinematic beacon light") as OmniLight3D if scanner != null else null
    var column := searchlight_tower.get_node_or_null("Faceted metallic tower") as MeshInstance3D if searchlight_tower != null else null
    if column == null or not (column.mesh is CylinderMesh) or searchlight_beam == null or beacon == null:
        _fail("V89 shaded 3D tower, swept translucent beam or moving beacon missing")
        return
    if not (searchlight_beam.mesh is ArrayMesh) or (searchlight_beam.mesh as ArrayMesh).surface_get_array_len(0) < 1200:
        _fail("V89 light shafts need detailed curved 3D mesh geometry")
        return
    var beam_material := searchlight_beam.material_override as StandardMaterial3D
    if beam_material == null or beam_material.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA or not beam_material.vertex_color_use_as_albedo:
        _fail("V89 light shafts must blend transparent vertex-color gradients")
        return
    var beam_colors: PackedColorArray = (searchlight_beam.mesh as ArrayMesh).surface_get_arrays(0)[Mesh.ARRAY_COLOR]
    if beam_colors.is_empty() or beam_colors[0].a >= 0.5 or beam_colors[beam_colors.size() / 2].a >= 0.5:
        _fail("V89 light shafts must be translucent rather than blocking the playfield")
        return
    if absf(searchlight_tower.position.x) < 8.0 or searchlights.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("V89 towers must stay outside race lanes and have no collisions")
        return
    var start_z := searchlight_tower.position.z
    var start_yaw := scanner.rotation.y
    searchlights.set("running", false)
    searchlights.call("_process", 0.5)
    if absf(searchlight_tower.position.z - start_z) > 0.001 or absf(scanner.rotation.y - start_yaw) > 0.001:
        _fail("V89 searchlights must freeze during quiz and menu states")
        return
    searchlights.set("running", true)
    searchlights.call("_process", 0.5)
    if searchlight_tower.position.z <= start_z or absf(scanner.rotation.y - start_yaw) < 0.05:
        _fail("V89 cinematic towers must scroll and sweep while racing")
        return
    searchlights.set("running", false)
    # V81: visible, independently animated 3D maglev convoys frame the
    # landscape playfield without adding collisions or changing gestures.
    var maglev := game.get_node_or_null("LearnQuest Skyway world/Cinematic maglev traffic") as Node3D
    if maglev == null or maglev.get("trains").size() != 2:
        _fail("Neon City needs two real animated maglev trains")
        return
    var train := maglev.get_node_or_null("Sky tram 0") as Node3D
    var car := train.get_node_or_null("Car 0") as Node3D if train != null else null
    var hull := car.get_node_or_null("Sculpted car hull") as MeshInstance3D if car != null else null
    var window := car.get_node_or_null("Side panoramic window") as MeshInstance3D if car != null else null
    var spark := train.get_node_or_null("Trailing energy spark 0") as MeshInstance3D if train != null else null
    if hull == null or not (hull.mesh is ArrayMesh) or (hull.mesh as ArrayMesh).surface_get_array_len(0) < 200:
        _fail("V81 trains need sculpted shaded hull meshes, not placeholder cubes")
        return
    # The hull must face outward: inward triangle winding is invisible with
    # normal back-face culling on iPhone and would look like a missing train.
    var hull_normals: PackedVector3Array = (hull.mesh as ArrayMesh).surface_get_arrays(0)[Mesh.ARRAY_NORMAL]
    if hull_normals.is_empty() or hull_normals[0].x < 0.3:
        _fail("V81 maglev hull has inward-facing triangles and will be culled")
        return
    if window == null or spark == null:
        _fail("V81 trains need real panoramic glass and animated energy trails")
        return
    var window_mat := window.material_override as StandardMaterial3D
    if window_mat == null or window_mat.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA:
        _fail("V81 maglev panoramic windows must be translucent")
        return
    if absf(train.position.x) < 9.0 or train.position.y < 6.0:
        _fail("V81 trains must stay above and outside the playable lanes")
        return
    var train_z := train.position.z
    var spark_size := spark.scale.x
    maglev.set("running", true)
    maglev.call("_process", 0.3)
    if train.position.z <= train_z or is_equal_approx(spark.scale.x, spark_size):
        _fail("V81 maglev movement or trailing spark animation is broken")
        return
    maglev.set("running", false)
    var paused_z := train.position.z
    maglev.call("_process", 0.3)
    if not is_equal_approx(train.position.z, paused_z):
        _fail("V81 trains must not move down the track during menus or quizzes")
        return
    # V86: two shaded 3D sky creatures flap real curved wings and travel
    # beside the road without intercepting touch input or creating collisions.
    var mantas := game.get_node_or_null("LearnQuest Skyway world/Cinematic sky mantas") as Node3D
    if mantas == null or mantas.get("creatures").size() != 2:
        _fail("V86 Neon City needs two animated holographic sky mantas")
        return
    var manta := mantas.get_node_or_null("Sky manta 0") as Node3D
    var manta_left_wing := manta.get_node_or_null("Left articulated wing") as Node3D if manta != null else null
    var manta_right_wing := manta.get_node_or_null("Right articulated wing") as Node3D if manta != null else null
    var manta_panel := manta_left_wing.get_node_or_null("Curved translucent wing membrane") as MeshInstance3D if manta_left_wing != null else null
    var manta_rim := manta_left_wing.get_node_or_null("Luminous trailing wing edge") as MeshInstance3D if manta_left_wing != null else null
    var manta_body := manta.get_node_or_null("Sculpted shaded manta body") as MeshInstance3D if manta != null else null
    var manta_tail := manta.get_node_or_null("Articulated comet tail") as Node3D if manta != null else null
    var manta_light := manta.get_node_or_null("Soft holographic manta light") as OmniLight3D if manta != null else null
    if manta_panel == null or manta_rim == null or manta_body == null or manta_right_wing == null or manta_tail == null or manta_light == null:
        _fail("V86 sky mantas require shaded bodies, articulated wings, tails and lights")
        return
    if not (manta_panel.mesh is ArrayMesh) or (manta_panel.mesh as ArrayMesh).surface_get_array_len(0) < 700:
        _fail("V86 sky manta wing must have a detailed original curved mesh")
        return
    if not (manta_body.mesh is ArrayMesh) or (manta_body.mesh as ArrayMesh).surface_get_array_len(0) < 900:
        _fail("V86 sky manta manta_body must be a sculpted 3D mesh")
        return
    var manta_mat := manta_panel.material_override as StandardMaterial3D
    if manta_mat == null or manta_mat.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA or not manta_mat.vertex_color_use_as_albedo or manta_mat.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED:
        _fail("V86 holographic wings need transparent, vertex-colored shaded surfaces")
        return
    if absf(manta.position.x) < 10.0 or manta.position.y < 7.0 or mantas.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("V86 holograms must remain outside playable lanes without collisions")
        return
    var manta_z := manta.position.z
    var wing_angle := manta_left_wing.rotation.z
    mantas.set("running", true)
    mantas.call("_process", 0.3)
    if manta.position.z <= manta_z or absf(manta_left_wing.rotation.z - wing_angle) < 0.05 or absf(manta_tail.rotation.y) < 0.03:
        _fail("V86 holographic mantas must travel and animate their wings and tails")
        return
    mantas.set("running", false)
    var manta_paused_z := manta.position.z
    mantas.call("_process", 0.3)
    if not is_equal_approx(manta.position.z, manta_paused_z):
        _fail("V86 holographic mantas must stop traveling during quizzes")
        return
    if game.get("rider") == null:
        _fail("Animated hoverboard character is missing")
        return
    var rider := game.get("rider") as Node3D
    if rider == null or rider.get_node_or_null("LegacyRider/Floating hoverboard") == null:
        _fail("Rider scene must preserve the animated hoverboard")
        return
    # V83: original curved ion ribbons and animated sparks improve the
    # 16:9 chase view without touching input, hitboxes or race mechanics.
    var wake := rider.get_node_or_null("LegacyRider/Floating hoverboard/Cinematic ion wake") as Node3D
    var wake_left := wake.get_node_or_null("Ion wake left") as Node3D if wake != null else null
    var wake_right := wake.get_node_or_null("Ion wake right") as Node3D if wake != null else null
    var ribbon := wake_left.get_node_or_null("Translucent curved plasma") as MeshInstance3D if wake_left != null else null
    var core := wake_left.get_node_or_null("Bright sculpted ion core") as MeshInstance3D if wake_left != null else null
    var engine_light := wake.get_node_or_null("Pulsing cinematic engine light") as OmniLight3D if wake != null else null
    if wake == null or wake_left == null or wake_right == null or ribbon == null or core == null or engine_light == null:
        _fail("V83 hoverboard must have two animated ion wakes and a cinematic light")
        return
    if not (ribbon.mesh is ArrayMesh) or (ribbon.mesh as ArrayMesh).surface_get_array_len(0) < 180:
        _fail("V83 ion wake needs a detailed original curved 3D mesh")
        return
    var ribbon_material := ribbon.material_override as StandardMaterial3D
    if ribbon_material == null or ribbon_material.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA or not ribbon_material.vertex_color_use_as_albedo:
        _fail("V83 ion ribbons need translucent vertex-colored gradients")
        return
    if wake.get("sparks").size() != 12 or wake.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("V83 ion wake must contain twelve moving sparks and no collisions")
        return
    var left_spark := wake_left.get_node_or_null("Moving ion spark 0") as MeshInstance3D
    var spark_z := left_spark.position.z
    var wake_normal_length := wake_left.scale.z
    var legacy_for_wake := rider.get_node("LegacyRider")
    legacy_for_wake.set("boosting", true)
    wake.call("_process", 0.24)
    if wake_left.scale.z <= wake_normal_length or is_equal_approx(left_spark.position.z, spark_z) or engine_light.light_energy <= 0.65:
        _fail("V83 Turbo must visibly extend the ion wakes, move sparks and brighten the light")
        return
    legacy_for_wake.set("boosting", false)
    wake.call("_process", 0.24)
    if wake_left.scale.z >= 0.95:
        _fail("V83 ion wakes must shrink again after Turbo ends")
        return
    var fallback := rider.get_node_or_null("LegacyRider/Animated racer rig") as Node3D
    if fallback == null:
        _fail("Legacy rider fallback must exist")
        return
    var installed_model := rider.get_node_or_null("ImportedRider")
    if installed_model == null:
        _fail("Bundled 3D rider model was not imported")
        return
    if fallback.visible:
        _fail("Fallback body must be hidden while imported 3D rider is active")
        return
    # V90: real jointed fabric motion, shaded original cloth and luminous
    # seams must remain visible in the landscape chase view, without hitboxes.
    var cloak := installed_model.get_node_or_null("AnimatedMotionCloak") as Node3D
    var cloak_left := cloak.get_node_or_null("LeftCloakRoot") as Node3D if cloak != null else null
    var cloak_right := cloak.get_node_or_null("RightCloakRoot") as Node3D if cloak != null else null
    if cloak_left == null or cloak_right == null or cloak.get("cloak_joints").size() != 6:
        _fail("V90 rider needs two three-joint animated flight cloak halves")
        return
    if cloak.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("V90 animated cloak must never alter collisions")
        return
    for cloak_side in ["LeftCloakRoot", "RightCloakRoot"]:
        var cloak_path: String = str(cloak_side)
        for segment in range(3):
            cloak_path += "/Joint%d" % segment
            var fabric_panel := cloak.get_node_or_null(cloak_path + "/FlowingFabric") as MeshInstance3D
            var outer_seam := cloak.get_node_or_null(cloak_path + "/LuminousOuterHem") as MeshInstance3D
            var inner_seam := cloak.get_node_or_null(cloak_path + "/LuminousInnerSeam") as MeshInstance3D
            if fabric_panel == null or outer_seam == null or inner_seam == null:
                _fail("V90 articulated cloak fabric or light seams are missing")
                return
            if not (fabric_panel.mesh is ArrayMesh) or (fabric_panel.mesh as ArrayMesh).surface_get_array_len(0) < 480:
                _fail("V90 cloth panels need detailed curved 3D surfaces")
                return
            var cloth_mat := fabric_panel.material_override as StandardMaterial3D
            var hem_mat := outer_seam.material_override as StandardMaterial3D
            if cloth_mat == null or not cloth_mat.vertex_color_use_as_albedo or cloth_mat.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED:
                _fail("V90 cloak must retain lit vertex-shaded fabric")
                return
            if hem_mat == null or not hem_mat.emission_enabled or not hem_mat.vertex_color_use_as_albedo:
                _fail("V90 cloak needs luminous gradient stitching")
                return
    rider.set("lean", 0.75)
    rider.set("boosting", true)
    cloak.call("_process", 0.3)
    var cloak_turbo_angle: float = cloak_left.rotation.z
    var cloak_first_joint := cloak_left.get_node("Joint0") as Node3D
    var cloak_turbo_pitch: float = cloak_first_joint.rotation.x
    if absf(cloak_turbo_angle) < 0.10 or absf(cloak_turbo_pitch) < 0.15:
        _fail("V90 cloak must visibly open and billow under Turbo and steering")
        return
    rider.set("lean", 0.0)
    rider.set("boosting", false)
    cloak.call("_process", 0.3)
    if absf(cloak_left.rotation.z) >= absf(cloak_turbo_angle) or absf(cloak_first_joint.rotation.x) >= absf(cloak_turbo_pitch):
        _fail("V90 articulated cloak must settle when Turbo ends")
        return
    var cloak_ground_pitch: float = cloak_first_joint.rotation.x
    rider.position.y = 1.4
    cloak.call("_process", 0.3)
    if absf(cloak_first_joint.rotation.x - cloak_ground_pitch) < 0.08:
        _fail("V90 cloak must respond to a real airborne pose")
        return
    rider.position.y = 0.0
    cloak.call("_process", 0.3)
    # V84: a clearly visible, animated 3D silhouette in the landscape chase
    # camera, built without assets, collisions or changes to touch controls.
    var sails := installed_model.get_node_or_null("AnimatedKineticSails") as Node3D
    var left_sail := sails.get_node_or_null("LeftSailPivot") as Node3D if sails != null else null
    var right_sail := sails.get_node_or_null("RightSailPivot") as Node3D if sails != null else null
    var membrane := left_sail.get_node_or_null("Feather0/CurvedEnergyMembrane") as MeshInstance3D if left_sail != null else null
    var vein := left_sail.get_node_or_null("Feather0/LuminousCenterSpine") as MeshInstance3D if left_sail != null else null
    if sails == null or left_sail == null or right_sail == null or membrane == null or vein == null:
        _fail("V84 rider must have two sculpted three-feather energy sails")
        return
    if not (membrane.mesh is ArrayMesh) or (membrane.mesh as ArrayMesh).surface_get_array_len(0) < 600:
        _fail("V84 wing membrane must use detailed curved 3D geometry")
        return
    var sail_material := membrane.material_override as StandardMaterial3D
    if sail_material == null or not sail_material.vertex_color_use_as_albedo or sail_material.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA:
        _fail("V84 energy sails must use translucent shaded vertex gradients")
        return
    if sails.get("feathers").size() != 6 or sails.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("V84 six articulated feathers must not change player collisions")
        return
    var resting_angle := left_sail.rotation.z
    rider.set("boosting", true)
    sails.call("_process", 0.25)
    var turbo_angle := left_sail.rotation.z
    var boosted_span := (left_sail.get_node("Feather0") as Node3D).scale.x
    if absf(turbo_angle - resting_angle) < 0.05 or boosted_span <= 1.0:
        _fail("V84 Turbo must visibly unfold the animated wings")
        return
    rider.set("boosting", false)
    sails.call("_process", 0.25)
    if absf(left_sail.rotation.z) >= absf(turbo_angle) or (left_sail.get_node("Feather0") as Node3D).scale.x >= boosted_span:
        _fail("V84 wings must fold back when Turbo ends")
        return
    # V52: showcase the real detailed rider from the front, with original
    # animated curved geometry, without replacing the playable hoverboard.
    var gallery := game.get_node_or_null("Cinematic hero gallery") as Node3D
    var portrait_camera := game.get("chase_camera") as Camera3D
    if gallery == null or portrait_camera == null or not gallery.visible:
        _fail("Cinematic hero showcase or camera is missing in the menu")
        return
    var halo := gallery.get_node_or_null("Layered luminous landing rings") as MeshInstance3D
    var arches := gallery.get_node_or_null("Sculpted cinematic light arches") as MeshInstance3D
    if halo == null or arches == null or not (halo.mesh is ArrayMesh) or not (arches.mesh is ArrayMesh):
        _fail("Showcase needs actual original 3D ring and curved arch meshes")
        return
    if (halo.mesh as ArrayMesh).surface_get_array_len(0) < 1000 or (arches.mesh as ArrayMesh).surface_get_array_len(0) < 1500:
        _fail("Cinematic gallery geometry is too sparse")
        return
    var gallery_material := arches.material_override as StandardMaterial3D
    if gallery_material == null or not gallery_material.vertex_color_use_as_albedo or gallery_material.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA:
        _fail("Gallery must preserve translucent neon vertex gradients")
        return
    if portrait_camera.position.z >= -3.0 or portrait_camera.fov >= 62.0:
        _fail("Menu must reveal the rider's front-facing face and hair")
        return
    var gallery_angle: float = halo.rotation.y
    gallery.call("_process", 0.5)
    if is_equal_approx(gallery_angle, halo.rotation.y):
        _fail("Gallery halo must animate")
        return
    var hairstyle := installed_model.get_node_or_null("RiderHair") as Node3D
    if hairstyle == null or hairstyle.get_child_count() < 8:
        _fail("The stylized 3D rider hair and animated locks are missing")
        return
    var hair_lock := hairstyle.get_node_or_null("WindHair1") as Node3D
    if hair_lock == null:
        _fail("The central wind-animated hair lock is missing")
        return
    var sculpted_lock := hair_lock.get_node_or_null("HairLock") as MeshInstance3D
    if sculpted_lock == null or not (sculpted_lock.mesh is ArrayMesh):
        _fail("Hair must use the new sculpted 3D lock mesh")
        return
    if (sculpted_lock.mesh as ArrayMesh).surface_get_array_len(0) < 200:
        _fail("Tapered hair mesh has insufficient geometry")
        return
    # V33: a continuous three-strand braid and two luminous hair clasps.
    var braid := installed_model.get_node_or_null("AnimatedBraidedPonytail") as Node3D
    var sway := braid.get_node_or_null("WindSwayPivot") as Node3D if braid != null else null
    if sway == null:
        _fail("Braided ponytail is not attached to the imported rider")
        return
    for strand in range(3):
        var part := sway.get_node_or_null("BraidedStrand%d" % strand) as MeshInstance3D
        if part == null or not (part.mesh is ArrayMesh) or (part.mesh as ArrayMesh).surface_get_array_len(0) < 1500:
            _fail("Interlaced hair geometry missing: strand %d" % strand)
            return
        var hair_material := part.material_override as StandardMaterial3D
        if hair_material == null or not hair_material.vertex_color_use_as_albedo:
            _fail("Braided hair must preserve shaded strand colors")
            return
    for clasp_name in ["RootClasp", "TipClasp"]:
        var clasp := sway.get_node_or_null(clasp_name) as MeshInstance3D
        if clasp == null or not (clasp.material_override as StandardMaterial3D).emission_enabled:
            _fail("Luminous hair clasp missing: " + clasp_name)
            return
    # V43: expressive face has original curved geometry and timed blinking.
    var face := installed_model.get_node_or_null("ExpressiveFace") as Node3D
    if face == null:
        _fail("Expressive facial rig is missing")
        return
    var smile := face.get_node_or_null("CurvedSmile") as MeshInstance3D
    if smile == null or not (smile.mesh is ArrayMesh) or (smile.mesh as ArrayMesh).surface_get_array_len(0) < 200:
        _fail("Sculpted curved smile mesh is missing")
        return
    for eye_name in ["LeftEye", "RightEye"]:
        var eye := face.get_node_or_null(eye_name) as Node3D
        if eye == null or eye.get_node_or_null("EyeGlint") == null:
            _fail("Layered eye and highlight missing: " + eye_name)
            return
    if float(face.call("_blink_factor", 3.90)) > 0.2 or not is_equal_approx(float(face.call("_blink_factor", 1.0)), 1.0):
        _fail("Expressive face blink timing is incorrect")
        return
    for index in range(5):
        var swept := hairstyle.get_node_or_null("SweptHair%d" % index) as MeshInstance3D
        if swept == null or not (swept.mesh is ArrayMesh) or (swept.mesh as ArrayMesh).surface_get_array_len(0) < 200:
            _fail("Sculpted hair crest lock is missing")
            return
    # V35: true volumetric hair shell, layered gradient strands and
    # articulated side curls, all with original curved mesh geometry.
    var volume := installed_model.get_node_or_null("SculptedVolumetricHair") as Node3D
    if volume == null:
        _fail("Volumetric hair sculpture is missing")
        return
    var scalp := volume.get_node_or_null("VolumetricScalp") as MeshInstance3D
    if scalp == null or not (scalp.mesh is ArrayMesh) or (scalp.mesh as ArrayMesh).surface_get_array_len(0) < 2400:
        _fail("Hair crown must have a detailed continuous 3D surface")
        return
    var scalp_material := scalp.material_override as StandardMaterial3D
    if scalp_material == null or not scalp_material.vertex_color_use_as_albedo:
        _fail("Hair crown needs the original shaded color gradient")
        return
    for layer in range(6):
        var swept := volume.get_node_or_null("SweptLayer%d" % layer) as MeshInstance3D
        var glint := volume.get_node_or_null("LuminousHairSheen%d" % layer) as MeshInstance3D
        if swept == null or not (swept.mesh is ArrayMesh) or (swept.mesh as ArrayMesh).surface_get_array_len(0) < 450:
            _fail("Detailed layered hair plate missing: %d" % layer)
            return
        if glint == null or not (glint.mesh is ArrayMesh) or not (glint.material_override as StandardMaterial3D).emission_enabled:
            _fail("Glowing hair highlight missing: %d" % layer)
            return
    for curl_name in ["LeftTempleCurl", "RightTempleCurl"]:
        var curl := volume.get_node_or_null(curl_name) as Node3D
        var strand := curl.get_node_or_null("SculptedCurl") as MeshInstance3D if curl != null else null
        if strand == null or not (strand.mesh is ArrayMesh) or (strand.mesh as ArrayMesh).surface_get_array_len(0) < 1000:
            _fail("Sculpted articulated temple curl missing: " + curl_name)
            return
    # V39: four substantial two-joint hair locks, shaded original geometry,
    # emissive filaments and independent wind response without changing gameplay.
    var cascade := installed_model.get_node_or_null("AnimatedWindHairCascade") as Node3D
    if cascade == null:
        _fail("Articulated hair cascade is missing")
        return
    for i in range(4):
        var root_lock := cascade.get_node_or_null("WindCascadeRoot%d" % i) as Node3D
        var tip_lock := root_lock.get_node_or_null("WindCascadeTip%d" % i) as Node3D if root_lock != null else null
        if root_lock == null or tip_lock == null:
            _fail("Two-joint hair strand is missing: %d" % i)
            return
        for segment in range(2):
            var pivot := root_lock if segment == 0 else tip_lock
            var sculpted := pivot.get_node_or_null("SculptedHairSegment%d" % segment) as MeshInstance3D
            var filament := pivot.get_node_or_null("LuminousHairFilament%d" % segment) as MeshInstance3D
            if sculpted == null or not (sculpted.mesh is ArrayMesh) or (sculpted.mesh as ArrayMesh).surface_get_array_len(0) < 1000:
                _fail("Detailed gradient hair segment missing: %d/%d" % [i, segment])
                return
            var gradient := sculpted.material_override as StandardMaterial3D
            if gradient == null or not gradient.vertex_color_use_as_albedo:
                _fail("Hair cascade must use original vertex-color shading")
                return
            if filament == null or not (filament.mesh is ArrayMesh):
                _fail("Sculpted hair filament missing: %d/%d" % [i, segment])
                return
            var neon := filament.material_override as StandardMaterial3D
            if neon == null or not neon.emission_enabled:
                _fail("Hair filament must emit light")
                return
    rider.set("boosting", true)
    rider.set("lean", 0.8)
    cascade.call("_process", 0.25)
    var root_motion := cascade.get_node("WindCascadeRoot0") as Node3D
    var tip_motion := root_motion.get_node("WindCascadeTip0") as Node3D
    if absf(root_motion.rotation.x) < 0.01 or absf(root_motion.rotation.z) < 0.01 or absf(tip_motion.rotation.x) < 0.01 or absf(tip_motion.rotation.z) < 0.01:
        _fail("Independent hair cascade joints must react to turbo and steering")
        return
    rider.set("boosting", false)
    rider.set("lean", 0.0)
    # V38: two real curved jacket panels, raised collar, sculpted chest
    # plates and an animated luminous zipper; gameplay nodes are untouched.
    var torso := installed_model.get_node_or_null("AnimatedTailoredFlightJacket") as Node3D
    if torso == null:
        _fail("Sculpted front flight jacket is missing")
        return
    var breathing := torso.get_node_or_null("AnimatedBreathingJacket") as Node3D
    if breathing == null:
        _fail("Animated breathing jacket pivot is missing")
        return
    for part_name in ["TailoredLeftChest", "TailoredRightChest"]:
        var panel := breathing.get_node_or_null(part_name) as MeshInstance3D
        if panel == null or not (panel.mesh is ArrayMesh) or (panel.mesh as ArrayMesh).surface_get_array_len(0) < 1500:
            _fail("Sculpted high-resolution jacket panel missing: " + part_name)
            return
        var fabric := panel.material_override as StandardMaterial3D
        if fabric == null or not fabric.vertex_color_use_as_albedo:
            _fail("Tailored jacket requires shaded fabric gradients")
            return
    for part_name in ["LayeredLeftChestArmor", "LayeredRightChestArmor"]:
        var armor_panel := breathing.get_node_or_null(part_name) as MeshInstance3D
        if armor_panel == null or not (armor_panel.mesh is ArrayMesh) or (armor_panel.mesh as ArrayMesh).surface_get_array_len(0) < 800:
            _fail("Sculpted chest armor missing: " + part_name)
            return
    var flight_collar := torso.get_node_or_null("RaisedFlightCollar") as MeshInstance3D
    if flight_collar == null or not (flight_collar.mesh is ArrayMesh) or (flight_collar.mesh as ArrayMesh).surface_get_array_len(0) < 1200:
        _fail("Continuous curved flight collar is missing")
        return
    for seam_name in ["LuminousCenterZipper", "LuminousWaistPiping", "LuminousLeftChestEdge", "LuminousRightChestEdge"]:
        var seam := breathing.get_node_or_null(seam_name) as MeshInstance3D
        if seam == null or not (seam.mesh is ArrayMesh) or (seam.mesh as ArrayMesh).surface_get_array_len(0) < 100:
            _fail("Curved jacket piping missing: " + seam_name)
            return
        var seam_mat := seam.material_override as StandardMaterial3D
        if seam_mat == null or not seam_mat.emission_enabled:
            _fail("Flight jacket neon piping is not emissive")
            return
    torso.call("_process", 0.20)
    if absf(breathing.scale.z - 1.0) < 0.001:
        _fail("Jacket breathing animation does not move the sculpted mesh")
        return
    var jacket := installed_model.get_node_or_null("SculptedJacketBack") as MeshInstance3D
    var emblem := installed_model.get_node_or_null("NeonJacketEmblem") as MeshInstance3D
    if jacket == null or not (jacket.mesh is ArrayMesh) or (jacket.mesh as ArrayMesh).surface_get_array_len(0) < 300:
        _fail("Sculpted jacket shell is missing or incomplete")
        return
    if emblem == null or emblem.mesh == null or emblem.mesh.get_surface_count() == 0:
        _fail("Glowing jacket emblem is missing")
        return
    var scarf := installed_model.get_node_or_null("AnimatedScarfTail0") as Node3D
    var cloth := scarf.get_node_or_null("FlowingCloth") as MeshInstance3D if scarf != null else null
    var hem := scarf.get_node_or_null("NeonHem") as MeshInstance3D if scarf != null else null
    if cloth == null or not (cloth.mesh is ArrayMesh) or (cloth.mesh as ArrayMesh).surface_get_array_len(0) < 250:
        _fail("Flowing scarf must use a detailed curved mesh rather than a box")
        return
    if hem == null or not (hem.mesh is ArrayMesh) or (hem.mesh as ArrayMesh).surface_get_array_len(0) < 250:
        _fail("Curved neon scarf hem is missing")
        return
    # Curved shoulder plates and their emissive piping must exist on both
    # articulated arms, with sufficient original mesh geometry.
    for arm_name in ["BalanceArm0", "BalanceArm1"]:
        var guard := installed_model.get_node_or_null(arm_name + "/SculptedShoulderGuard") as MeshInstance3D
        var trim := installed_model.get_node_or_null(arm_name + "/ShoulderNeonTrim") as MeshInstance3D
        if guard == null or not (guard.mesh is ArrayMesh) or (guard.mesh as ArrayMesh).surface_get_array_len(0) < 700:
            _fail("Sculpted shoulder armor is missing on " + arm_name)
            return
        if trim == null or not (trim.mesh is ArrayMesh) or (trim.mesh as ArrayMesh).surface_get_array_len(0) < 150:
            _fail("Curved neon shoulder piping is missing on " + arm_name)
            return
        var trim_material := trim.material_override as StandardMaterial3D
        if trim_material == null or not trim_material.emission_enabled:
            _fail("Neon shoulder piping is not emissive on " + arm_name)
            return
    # V37: each hand has a shaped forearm, knuckles, articulated fingers
    # and a curved emissive wrist display, not just the legacy hand sphere.
    for arm_name in ["BalanceArm0", "BalanceArm1"]:
        var gauntlet := installed_model.get_node_or_null(arm_name + "/SculptedRiderGauntlet") as Node3D
        if gauntlet == null:
            _fail("Sculpted glove missing on " + arm_name)
            return
        for part_name in ["SculptedForearmShell", "LayeredKnuckleGuard", "LuminousGauntletSeams"]:
            var part := gauntlet.get_node_or_null(part_name) as MeshInstance3D
            if part == null or not (part.mesh is ArrayMesh) or (part.mesh as ArrayMesh).surface_get_array_len(0) < 180:
                _fail("Gauntlet mesh missing: " + arm_name + "/" + part_name)
                return
        var fabric := (gauntlet.get_node("SculptedForearmShell") as MeshInstance3D).material_override as StandardMaterial3D
        if fabric == null or not fabric.vertex_color_use_as_albedo:
            _fail("Gauntlet must retain sculpted fabric gradients")
            return
        var display := gauntlet.get_node_or_null("AnimatedWristDisplay/CurvedHolographicDisplay") as MeshInstance3D
        if display == null or not (display.mesh is ArrayMesh) or (display.mesh as ArrayMesh).surface_get_array_len(0) < 700:
            _fail("Curved wrist hologram missing on " + arm_name)
            return
        var display_material := display.material_override as StandardMaterial3D
        if display_material == null or not display_material.emission_enabled:
            _fail("Wrist display must glow")
            return
        for finger_index in range(4):
            var finger := gauntlet.get_node_or_null("ArticulatedFinger%d/TaperedFingerMesh" % finger_index) as MeshInstance3D
            if finger == null or not (finger.mesh is ArrayMesh) or (finger.mesh as ArrayMesh).surface_get_array_len(0) < 400:
                _fail("Articulated finger missing: " + arm_name)
                return
        if gauntlet.get_node_or_null("SculptedThumb") == null:
            _fail("Sculpted thumb missing: " + arm_name)
            return
    # V32: custom-meshed high-top footwear follows both articulated legs.
    for leg_name in ["BalanceLeg0", "BalanceLeg1"]:
        var footwear := installed_model.get_node_or_null(leg_name + "/SculptedHoverBoot") as Node3D
        if footwear == null:
            _fail("Animated high-top boot missing: " + leg_name)
            return
        for mesh_name in ["SculptedUpper", "SculptedSole"]:
            var part := footwear.get_node_or_null(mesh_name) as MeshInstance3D
            if part == null or not (part.mesh is ArrayMesh) or (part.mesh as ArrayMesh).surface_get_array_len(0) < 1000:
                _fail("Boot needs detailed sculpted geometry: " + leg_name + "/" + mesh_name)
                return
        for detail_name in ["NeonSoleWelt", "WovenLaces"]:
            var detail := footwear.get_node_or_null(detail_name) as MeshInstance3D
            if detail == null or not (detail.mesh is ArrayMesh):
                _fail("Boot detail missing: " + leg_name + "/" + detail_name)
                return
            var detail_material := detail.material_override as StandardMaterial3D
            if detail_material == null or not detail_material.emission_enabled:
                _fail("Boot edge and laces must glow")
                return
        if footwear.get_node_or_null("TailoredAnkleCuff") == null:
            _fail("Boot ankle cuff missing: " + leg_name)
            return
    # V34: original sculpted fabric legs and articulated knee armor.
    for leg_name in ["BalanceLeg0", "BalanceLeg1"]:
        var leg_armor := installed_model.get_node_or_null(leg_name + "/SculptedRiderLeg") as Node3D
        if leg_armor == null:
            _fail("Tailored rider leg mesh missing: " + leg_name)
            return
        var trousers := leg_armor.get_node_or_null("TailoredTrouserShell") as MeshInstance3D
        var seams := leg_armor.get_node_or_null("LuminousSideSeams") as MeshInstance3D
        var knee := leg_armor.get_node_or_null("KneeArmorPivot") as Node3D
        var guard := knee.get_node_or_null("CurvedKneeGuard") as MeshInstance3D if knee != null else null
        var trim := knee.get_node_or_null("KneeNeonPiping") as MeshInstance3D if knee != null else null
        if trousers == null or not (trousers.mesh is ArrayMesh) or (trousers.mesh as ArrayMesh).surface_get_array_len(0) < 1600:
            _fail("Sculpted trouser shell needs detailed original mesh: " + leg_name)
            return
        var fabric := trousers.material_override as StandardMaterial3D
        if fabric == null or not fabric.vertex_color_use_as_albedo:
            _fail("Trouser fabric gradient missing: " + leg_name)
            return
        if seams == null or not (seams.mesh is ArrayMesh) or (seams.material_override as StandardMaterial3D) == null or not (seams.material_override as StandardMaterial3D).emission_enabled:
            _fail("Glowing trouser seams missing: " + leg_name)
            return
        if guard == null or not (guard.mesh is ArrayMesh) or (guard.mesh as ArrayMesh).surface_get_array_len(0) < 800:
            _fail("Sculpted articulated knee guard missing: " + leg_name)
            return
        if trim == null or not (trim.mesh is ArrayMesh) or (trim.material_override as StandardMaterial3D) == null or not (trim.material_override as StandardMaterial3D).emission_enabled:
            _fail("Glowing knee armor piping missing: " + leg_name)
            return
    # V43: mesh-built two-panel coat, gradient fabric, luminous seams and collar.
    var coat := installed_model.get_node_or_null("AnimatedSculptedCoat") as Node3D
    if coat == null:
        _fail("Sculpted animated coat is missing")
        return
    for tail_name in ["LeftCoatTail", "RightCoatTail"]:
        var tail := coat.get_node_or_null(tail_name) as Node3D
        var coat_cloth := tail.get_node_or_null("SculptedCloth") as MeshInstance3D if tail != null else null
        var seams := tail.get_node_or_null("NeonSeams") as MeshInstance3D if tail != null else null
        if coat_cloth == null or not (coat_cloth.mesh is ArrayMesh) or (coat_cloth.mesh as ArrayMesh).surface_get_array_len(0) < 650:
            _fail("Detailed curved coat fabric missing: " + tail_name)
            return
        if seams == null or not (seams.mesh is ArrayMesh) or (seams.mesh as ArrayMesh).surface_get_array_len(0) < 200:
            _fail("Glowing tailored coat seams missing: " + tail_name)
            return
        var seam_material := seams.material_override as StandardMaterial3D
        if seam_material == null or not seam_material.emission_enabled:
            _fail("Coat seams must be emissive")
            return
    var collar := coat.get_node_or_null("RaisedSculptedCollar") as MeshInstance3D
    var collar_light := coat.get_node_or_null("CollarLight") as MeshInstance3D
    if collar == null or not (collar.mesh is ArrayMesh) or (collar.mesh as ArrayMesh).surface_get_array_len(0) < 100 or collar_light == null:
        _fail("Raised curved collar and luminous trim are missing")
        return
    # V43: original articulated aerofoil costume must have sculpted geometry.
    var aero := installed_model.get_node_or_null("AnimatedAeroWings") as Node3D
    if aero == null:
        _fail("Animated sculpted aerofoil costume is missing")
        return
    for side_name in ["LeftWing", "RightWing"]:
        var wing := aero.get_node_or_null(side_name) as Node3D
        if wing == null:
            _fail("Articulated aerofoil missing: " + side_name)
            return
        for fin_name in ["SculptedUpperFin", "SculptedLowerFin"]:
            var fin := wing.get_node_or_null(fin_name) as MeshInstance3D
            if fin == null or not (fin.mesh is ArrayMesh) or (fin.mesh as ArrayMesh).surface_get_array_len(0) < 700:
                _fail("Detailed sculpted wing geometry missing: " + side_name + "/" + fin_name)
                return
        for edge_name in ["UpperNeonEdge", "LowerNeonEdge", "UpperNeonVein", "LowerNeonVein"]:
            var light := wing.get_node_or_null(edge_name) as MeshInstance3D
            if light == null or not (light.mesh is ArrayMesh) or not (light.material_override as StandardMaterial3D).emission_enabled:
                _fail("Luminous aerofoil edge missing: " + side_name + "/" + edge_name)
                return
    # V36: the sculpted aero harness must be visible, vertex-shaded and animated.
    var harness := installed_model.get_node_or_null("AnimatedAeroHarness") as Node3D
    if harness == null:
        _fail("Back-mounted aero harness is missing")
        return
    var plate := harness.get_node_or_null("CurvedAeroBackplate") as MeshInstance3D
    if plate == null or not (plate.mesh is ArrayMesh) or (plate.mesh as ArrayMesh).surface_get_array_len(0) < 1400:
        _fail("Curved back armor requires detailed original mesh geometry")
        return
    var plate_material := plate.material_override as StandardMaterial3D
    if plate_material == null or not plate_material.vertex_color_use_as_albedo:
        _fail("Back armor color gradients are missing")
        return
    var reactor := harness.get_node_or_null("RotatingEnergyReactor") as Node3D
    var ring := reactor.get_node_or_null("SculptedReactorRing") as MeshInstance3D if reactor != null else null
    if ring == null or not (ring.mesh is ArrayMesh) or (ring.mesh as ArrayMesh).surface_get_array_len(0) < 250:
        _fail("Sculpted rotating reactor ring is missing")
        return
    for thruster_name in ["LeftAeroThruster", "RightAeroThruster"]:
        var thruster := harness.get_node_or_null(thruster_name) as Node3D
        var housing := thruster.get_node_or_null("SculptedThrusterHousing") as MeshInstance3D if thruster != null else null
        var plume := thruster.get_node_or_null("NeonExhaustPlume") as MeshInstance3D if thruster != null else null
        if housing == null or not (housing.mesh is ArrayMesh) or (housing.mesh as ArrayMesh).surface_get_array_len(0) < 1200:
            _fail("Sculpted thruster housing is missing: " + thruster_name)
            return
        if plume == null or not (plume.mesh is ArrayMesh) or not (plume.material_override as StandardMaterial3D).emission_enabled:
            _fail("Neon thruster exhaust is missing: " + thruster_name)
            return
    var old_reactor_angle := reactor.rotation.z
    rider.set("boosting", true)
    rider.set("lean", 0.8)
    await process_frame
    if reactor.rotation.z <= old_reactor_angle or absf(reactor.scale.x - 1.0) < 0.001:
        _fail("Aero reactor did not animate under turbo")
        return
    var glove := installed_model.get_node("BalanceArm0/SculptedRiderGauntlet") as Node3D
    var finger := glove.get_node("ArticulatedFinger0") as Node3D
    var display_pivot := glove.get_node("AnimatedWristDisplay") as Node3D
    if finger.rotation.x <= 0.0 or absf(display_pivot.rotation.z) < 0.001:
        _fail("Gauntlet fingers and wrist display must respond to turbo and steering")
        return
    var left_thruster := harness.get_node("LeftAeroThruster") as Node3D
    if absf(left_thruster.rotation.z) < 0.001:
        _fail("Aero thrusters must react to steering")
        return
    if absf(scarf.rotation.x) < 0.001:
        _fail("Flowing scarf did not respond to rider motion")
        return
    if absf(hair_lock.rotation.x) < 0.001 or absf(hair_lock.rotation.z) < 0.001:
        _fail("The 3D rider hair is not responding to turbo and steering")
        return
    var temple := volume.get_node("LeftTempleCurl") as Node3D
    if absf(temple.rotation.x) < 0.001 or absf(temple.rotation.z) < 0.001:
        _fail("Sculpted temple hair must respond to turbo and steering")
        return
    var left_tail := coat.get_node("LeftCoatTail") as Node3D
    if left_tail.rotation.x >= 0.0:
        _fail("Coat fabric does not respond to turbo wind")
        return
    var left_wing := aero.get_node("LeftWing") as Node3D
    if absf(left_wing.rotation.z) < 0.001 or absf(left_wing.rotation.x) < 0.001:
        _fail("Articulated aerofoil does not react to steering and turbo")
        return
    if absf(sway.rotation.x) < 0.001 or absf(sway.rotation.z) < 0.001:
        _fail("Braided ponytail must sway with turbo and steering")
        return
    rider.set("boosting", false)
    rider.set("lean", 0.0)
    # V88: the imported rider must visibly tuck its knees and spread both arms
    # while airborne. Curved windstream meshes and landing shards are purely
    # visual, with no collision objects or input modifications.
    var aerial_fx := rider.get_node_or_null("Cinematic aerial choreography") as Node3D
    var left_air := aerial_fx.get_node_or_null("Left sculpted aerial ribbon") as MeshInstance3D if aerial_fx != null else null
    var right_air := aerial_fx.get_node_or_null("Right sculpted aerial ribbon") as MeshInstance3D if aerial_fx != null else null
    var shard := aerial_fx.get_node_or_null("Landing energy shard 0") as MeshInstance3D if aerial_fx != null else null
    var landing_flash := aerial_fx.get_node_or_null("Soft cinematic landing flash") as OmniLight3D if aerial_fx != null else null
    if left_air == null or right_air == null or shard == null or landing_flash == null:
        _fail("V88 aerial ribbons, landing shards or cinematic flash are missing")
        return
    if not (left_air.mesh is ArrayMesh) or (left_air.mesh as ArrayMesh).surface_get_array_len(0) < 150:
        _fail("V88 windstream must be an original detailed curved 3D mesh")
        return
    var aerial_mat := left_air.material_override as StandardMaterial3D
    if aerial_mat == null or not aerial_mat.vertex_color_use_as_albedo or aerial_mat.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA:
        _fail("V88 aerial windstream requires translucent vertex-color shading")
        return
    if aerial_fx.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("V88 aerial effects must not introduce collision geometry")
        return
    var aerial_arm := installed_model.get_node("BalanceArm0") as Node3D
    var aerial_leg := installed_model.get_node("BalanceLeg0") as Node3D
    rider.call("_process", 0.18)
    var grounded_arm_z := aerial_arm.rotation.z
    var grounded_leg_x := aerial_leg.rotation.x
    rider.position.y = 1.4
    rider.call("_process", 0.24)
    aerial_fx.call("update_visuals", 0.24, 1.4, 0.0, false)
    if float(rider.get("aerial_pose")) < 0.5 or absf(aerial_arm.rotation.z - grounded_arm_z) < 0.08 or absf(aerial_leg.rotation.x - grounded_leg_x) < 0.08:
        _fail("V88 airborne character must animate arms and legs distinctly")
        return
    if not left_air.visible or not right_air.visible or float(aerial_fx.get("air_weight")) < 0.5:
        _fail("V88 sculpted windstreams must unfurl during a real jump")
        return
    rider.position.y = 0.0
    aerial_fx.call("update_visuals", 0.06, 0.0, 0.0, false)
    if not shard.visible or landing_flash.light_energy <= 0.0:
        _fail("V88 landing must emit animated 3D shards and a short light flash")
        return
    aerial_fx.call("update_visuals", 0.8, 0.0, 0.0, false)
    if shard.visible or left_air.visible or landing_flash.light_energy > 0.0:
        _fail("V88 cinematic jump effects must disappear after landing")
        return
    # V88: projected board shadow and cinematic rim light remain anchored to
    # the road while the rider jumps; turbo ribbons appear only during racing.
    var rider_lighting := game.get_node_or_null("Cinematic rider lighting") as Node3D
    var contact_shadow := rider_lighting.get_node_or_null("Soft projected hoverboard shadow") as MeshInstance3D if rider_lighting != null else null
    var ground_glow := rider_lighting.get_node_or_null("Layered hoverboard ground glow") as MeshInstance3D if rider_lighting != null else null
    var cinematic_rim := rider_lighting.get_node_or_null("Dynamic colored rider rim light") as OmniLight3D if rider_lighting != null else null
    var left_speed := rider_lighting.get_node_or_null("Left cinematic ground speed ribbon") as MeshInstance3D if rider_lighting != null else null
    var right_speed := rider_lighting.get_node_or_null("Right cinematic ground speed ribbon") as MeshInstance3D if rider_lighting != null else null
    if contact_shadow == null or ground_glow == null or cinematic_rim == null or left_speed == null or right_speed == null:
        _fail("V88 cinematic shadow, ground glow, rim lighting or turbo ribbons missing")
        return
    if not (contact_shadow.mesh is ArrayMesh) or (contact_shadow.mesh as ArrayMesh).surface_get_array_len(0) < 1000:
        _fail("V88 contact shadow needs a detailed feathered 3D disc")
        return
    if not (ground_glow.mesh is ArrayMesh) or not (left_speed.mesh is ArrayMesh) or (left_speed.mesh as ArrayMesh).surface_get_array_len(0) < 150:
        _fail("V88 glowing ground halo and curved speed ribbons must be original meshes")
        return
    var contact_material := contact_shadow.material_override as StandardMaterial3D
    if contact_material == null or not contact_material.vertex_color_use_as_albedo or contact_material.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA:
        _fail("V88 ground shadow requires soft translucent vertex shading")
        return
    if rider_lighting.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("V88 cinematic lighting must not change rider collision or touch input")
        return
    rider_lighting.call("update_visuals", 0.1, Vector3(3.1, 0.0, 0.2), 0, 0.0, false, true)
    var grounded_fade := contact_shadow.transparency
    var city_tint := cinematic_rim.light_color
    var idle_energy := cinematic_rim.light_energy
    if absf(rider_lighting.position.x - 3.1) > 0.001 or absf(rider_lighting.position.y) > 0.001 or left_speed.visible:
        _fail("V88 contact lighting must track the lane without unintended turbo ribbons")
        return
    rider_lighting.call("update_visuals", 0.1, Vector3(-3.1, 1.8, 0.2), 2, 1.8, false, true)
    if contact_shadow.transparency <= grounded_fade or absf(rider_lighting.position.y) > 0.001 or cinematic_rim.light_color == city_tint:
        _fail("V88 airborne shadow must fade and the four worlds must have distinct rim lighting")
        return
    rider_lighting.call("update_visuals", 0.1, Vector3(0.0, 0.0, 0.2), 2, 0.0, true, true)
    if not left_speed.visible or not right_speed.visible or cinematic_rim.light_energy <= idle_energy or ground_glow.scale.x <= 1.0:
        _fail("V88 Turbo must illuminate the rider and reveal ground speed ribbons")
        return
    rider_lighting.call("update_visuals", 0.1, Vector3(0.0, 0.0, 0.2), 2, 0.0, true, false)
    if left_speed.visible or right_speed.visible or cinematic_rim.light_energy > idle_energy + 0.001:
        _fail("V88 cinematic Turbo ribbons must disappear in quiz/menu states")
        return
    # Exercise the new replacement contract without requiring any paid model.
    var placeholder := Node3D.new()
    rider.call("set_character_model", placeholder)
    if rider.get_node_or_null("ImportedRider") == null or fallback.visible:
        _fail("Imported visual does not replace the legacy character correctly")
        return
    rider.call("restore_fallback")
    if not fallback.visible:
        _fail("Restoring the legacy character failed")
        return
    # Regression: jumping moves the RiderCharacter root, not its LegacyRider child.
    rider.position.y = 1.4
    await process_frame
    await process_frame
    var legacy := rider.get_node("LegacyRider")
    if float(legacy.get("jump_pose")) <= 0.0:
        _fail("Hoverboard rider does not animate during a real jump")
        return
    rider.position.y = 0.0
    await process_frame
    if float(legacy.get("landing_pulse")) <= 0.0:
        _fail("Hoverboard landing shockwave did not trigger")
        return
    var items := game.get("run_items") as Node3D
    if items == null or items.get_child_count() < 10:
        _fail("Obstacles and pickups were not created")
        return
    # Simulate portrait and desktop viewport widths without a real phone.
    var controls := game.get("controls_grid") as GridContainer
    if controls == null or controls.get_child_count() != 4:
        _fail("Hoverboard touch controls are missing")
        return
    game.call("_apply_mobile_layout", 390.0)
    if controls.columns != 2 or controls.offset_top > -130.0:
        _fail("Phone portrait controls must use two rows")
        return
    for panel in [game.get("splash"), game.get("quiz_box"), game.get("end_panel")]:
        if (panel as PanelContainer).custom_minimum_size.x > 366.0:
            _fail("Phone portrait overlay exceeds the available width")
            return
    var mobile_hud := game.get("hud") as Label
    var hud_panel := game.get("hud_panel") as PanelContainer
    if mobile_hud == null or hud_panel == null:
        _fail("Race HUD or its panel is missing")
        return
    if not mobile_hud.text.contains("V90") or not mobile_hud.text.contains("\n") or not mobile_hud.text.contains("KOMBO x0"):
        _fail("Phone portrait HUD must display version, stats and combo on separate lines")
        return
    if hud_panel.custom_minimum_size.x > 360.0:
        _fail("Phone portrait HUD panel is too wide")
        return
    game.call("_apply_mobile_layout", 960.0)
    if controls.columns != 4:
        _fail("Desktop controls must return to one row")
        return
    if not mobile_hud.text.contains("SKYWAY V90") or mobile_hud.text.contains("\n"):
        _fail("Desktop HUD must return to its single-line layout")
        return
    game.call("_start_game")
    # V52: real native screen touch events, not mouse-button stand-ins.
    # Dragging across the road steers immediately, clamped to three lanes.
    game.call("_input", _screen_touch(0, true, Vector2(500, 300)))
    game.call("_input", _screen_drag(0, Vector2(630, 300)))
    if int(game.get("lane")) != 1:
        _fail("Horizontal finger drag did not immediately steer right")
        return
    game.call("_input", _screen_drag(0, Vector2(100, 300)))
    if int(game.get("lane")) != -1:
        _fail("Finger drag did not steer left or clamp to the leftmost lane")
        return
    game.call("_input", _screen_touch(0, false, Vector2(100, 300)))
    game.set("lane", 0)
    game.call("_input", _screen_drag(9, Vector2(900, 300)))
    if int(game.get("lane")) != 0:
        _fail("Uncaptured or stray finger drag changed the lane")
        return
    # One-finger upward swipe jumps, and two taps at one spot activate Turbo.
    game.call("_input", _screen_touch(0, true, Vector2(520, 360)))
    game.call("_input", _screen_drag(0, Vector2(520, 250)))
    if float(game.get("jump_left")) <= 0.0:
        _fail("Upward swipe did not jump immediately while the finger was moving")
        return
    game.set("jump_left", 0.0)
    game.call("_input", _screen_touch(0, false, Vector2(520, 230)))
    if float(game.get("jump_left")) > 0.0:
        _fail("Releasing an already-triggered swipe caused a second jump")
        return
    game.set("power", 100)
    game.call("_input", _screen_touch(0, true, Vector2(520, 300)))
    game.call("_input", _screen_touch(0, false, Vector2(520, 300)))
    game.call("_input", _screen_touch(0, true, Vector2(520, 300)))
    game.call("_input", _screen_touch(0, false, Vector2(520, 300)))
    if float(game.get("turbo_left")) <= 0.0 or int(game.get("power")) != 60:
        _fail("Double-tap Turbo must activate exactly once and cost 40 energy")
        return
    # Two simultaneous fingers are a shield tap, not two Turbo taps.
    game.set("power", 100)
    game.call("_input", _screen_touch(0, true, Vector2(500, 300)))
    game.call("_input", _screen_touch(1, true, Vector2(590, 300)))
    game.call("_input", _screen_touch(0, false, Vector2(500, 300)))
    game.call("_input", _screen_touch(1, false, Vector2(590, 300)))
    if float(game.get("shield_left")) <= 0.0 or int(game.get("power")) != 70:
        _fail("Two-finger shield tap failed or spent incorrect energy")
        return
    # Two-finger upward swipe triggers the attack without an extra jump.
    game.set("power", 100)
    game.set("jump_left", 0.0)
    game.call("_input", _screen_touch(0, true, Vector2(500, 370)))
    game.call("_input", _screen_touch(1, true, Vector2(590, 370)))
    game.call("_input", _screen_drag(0, Vector2(500, 250)))
    if float(game.get("attack_left")) > 0.0 or int(game.get("power")) != 100:
        _fail("V55 one-finger movement spent attack energy")
        return
    game.call("_input", _screen_drag(1, Vector2(590, 250)))
    if float(game.get("attack_left")) <= 0.0 or int(game.get("power")) != 55 or float(game.get("jump_left")) > 0.0:
        _fail("V55 attack must spend exactly 45 energy DURING the second drag")
        return
    game.call("_input", _screen_touch(0, false, Vector2(500, 230)))
    game.call("_input", _screen_touch(1, false, Vector2(590, 230)))
    if float(game.get("attack_left")) <= 0.0 or int(game.get("power")) != 55 or float(game.get("jump_left")) > 0.0:
        _fail("V55 release repeated attack or caused an accidental jump")
        return
    # UI origins cannot capture steering, even when the finger leaves the UI.
    game.set("lane", 0)
    var blocked_control := controls.get_global_rect().get_center()
    if not bool(game.call("_touch_ui_blocked", blocked_control)):
        _fail("Visible touch buttons must be marked as protected UI")
        return
    game.call("_input", _screen_touch(0, true, blocked_control))
    game.call("_input", _screen_drag(0, blocked_control + Vector2(250, -200)))
    game.call("_input", _screen_touch(0, false, blocked_control + Vector2(250, -200)))
    if int(game.get("lane")) != 0:
        _fail("Touch beginning on UI accidentally steered the rider")
        return
    # A second finger touching a visible button must cancel an active swipe.
    game.set("jump_left", 0.0)
    game.set("lane", 0)
    game.call("_input", _screen_touch(0, true, Vector2(500, 350)))
    game.call("_input", _screen_touch(1, true, blocked_control))
    game.call("_input", _screen_drag(0, Vector2(500, 220)))
    game.call("_input", _screen_touch(0, false, Vector2(500, 220)))
    game.call("_input", _screen_touch(1, false, blocked_control))
    if float(game.get("jump_left")) > 0.0 or int(game.get("lane")) != 0:
        _fail("Second UI finger failed to cancel the active gameplay gesture")
        return
    # A three-finger tap must never spend energy or trigger a Shield.
    game.set("shield_left", 0.0)
    game.set("power", 100)
    game.call("_input", _screen_touch(0, true, Vector2(500, 300)))
    game.call("_input", _screen_touch(1, true, Vector2(590, 300)))
    game.call("_input", _screen_touch(0, false, Vector2(500, 300)))
    game.call("_input", _screen_touch(2, true, Vector2(660, 300)))
    game.call("_input", _screen_touch(1, false, Vector2(590, 300)))
    game.call("_input", _screen_touch(2, false, Vector2(660, 300)))
    if float(game.get("shield_left")) > 0.0 or int(game.get("power")) != 100:
        _fail("Three-finger touch accidentally activated an energy ability")
        return
    # The accessibility controls can be hidden and independently restored.
    game.call("_apply_mobile_layout", 390.0)
    game.call("_toggle_touch_buttons")
    if controls.visible or (game.get("powerups_grid") as GridContainer).visible:
        _fail("Mobile hide-buttons toggle did not hide both control rows")
        return
    # V69: the bottom gesture instructions are a passive, mouse-ignored label.
    # When buttons are hidden, their full-width label must not create a dead
    # strip of playfield where thumb drags and swipes silently stop working.
    var gesture_instructions := game.get("gesture_hint") as Label
    if gesture_instructions == null or not gesture_instructions.visible or gesture_instructions.mouse_filter != Control.MOUSE_FILTER_IGNORE:
        _fail("V69 gesture instructions must be a visible pass-through label")
        return
    var hint_touch := gesture_instructions.get_global_rect().get_center()
    if bool(game.call("_touch_ui_blocked", hint_touch)):
        _fail("V69 passive gesture instructions block the lower playfield")
        return
    # A real swipe starting on the instructions must steer immediately.
    game.set("lane", 0)
    game.call("_input", _screen_touch(0, true, hint_touch))
    game.call("_input", _screen_drag(0, hint_touch + Vector2(100, 0)))
    if int(game.get("lane")) != 1:
        _fail("V69 drag over passive instructions failed to steer")
        return
    game.call("_input", _screen_touch(0, false, hint_touch + Vector2(100, 0)))
    game.set("lane", 0)
    var restore := game.get("gesture_toggle") as Button
    if restore == null or not restore.visible or restore.text != "TASTEN EIN":
        _fail("Restoring hidden accessibility buttons must stay possible")
        return
    game.call("_toggle_touch_buttons")
    if not controls.visible or not (game.get("powerups_grid") as GridContainer).visible:
        _fail("Accessible touch buttons could not be restored")
        return
    # V59: an iPhone in landscape is wider than 720px but still needs the
    # optional gesture-only mode. Simulate touch hardware in headless CI.
    game.call("_apply_mobile_layout", 844.0, 1, 390.0)
    if not mobile_hud.text.contains("V90") or not mobile_hud.text.contains("\n"):
        _fail("Landscape-first phone layout must use a compact two-line HUD")
        return
    if not bool(game.get("touch_screen_mode")) or not restore.visible:
        _fail("V59 landscape touchscreen lost its button-visibility toggle")
        return
    if controls.columns != 4:
        _fail("V59 landscape touchscreen should keep the wide HUD layout")
        return
    var landscape_toggle_point := restore.get_global_rect().get_center()
    if not bool(game.call("_touch_ui_blocked", landscape_toggle_point)):
        _fail("V59 landscape toggle must remain protected from game gestures")
        return
    game.call("_toggle_touch_buttons")
    if controls.visible or (game.get("powerups_grid") as GridContainer).visible or not restore.visible:
        _fail("V59 landscape touchscreen cannot hide accessibility buttons")
        return
    # Rotating back to portrait and landscape must preserve the choice.
    game.call("_apply_mobile_layout", 390.0, 1)
    game.call("_apply_mobile_layout", 844.0, 1)
    if controls.visible or (game.get("powerups_grid") as GridContainer).visible or restore.text != "TASTEN EIN":
        _fail("V59 rotating a phone unexpectedly restored hidden buttons")
        return
    game.call("_toggle_touch_buttons")
    if not controls.visible or not (game.get("powerups_grid") as GridContainer).visible:
        _fail("V59 landscape touchscreen cannot restore accessibility buttons")
        return
    game.call("_apply_mobile_layout", 960.0, 0)
    if bool(game.get("touch_screen_mode")) or restore.visible or not controls.visible:
        _fail("V59 non-touch desktop must retain its visible controls")
        return
    # V63: rotating an iPhone while a finger is held must invalidate its
    # original coordinates; the stale drag/release must not move the rider.
    game.call("_apply_mobile_layout", 390.0, 1)
    game.set("jump_left", 0.0)
    game.set("lane", 0)
    game.call("_input", _screen_touch(0, true, Vector2(300, 260)))
    var rotation_gestures = game.get("touch_steering")
    if rotation_gestures.fingers.size() != 1:
        _fail("V63 test setup failed to capture playfield touch")
        return
    game.call("_apply_mobile_layout", 844.0, 1)
    if not rotation_gestures.fingers.is_empty():
        _fail("V63 orientation change must clear in-flight touch state")
        return
    game.call("_input", _screen_drag(0, Vector2(300, 120)))
    game.call("_input", _screen_touch(0, false, Vector2(300, 120)))
    if float(game.get("jump_left")) > 0.0 or int(game.get("lane")) != 0:
        _fail("V63 stale touch after rotation triggered gameplay movement")
        return
    # A fresh deliberate swipe must work immediately after the relayout.
    game.call("_input", _screen_touch(0, true, Vector2(300, 260)))
    game.call("_input", _screen_drag(0, Vector2(300, 120)))
    if float(game.get("jump_left")) <= 0.0:
        _fail("V63 rotation must not disable fresh touch gestures")
        return
    game.call("_input", _screen_touch(0, false, Vector2(300, 120)))
    game.set("jump_left", 0.0)
    # V64: Safari browser chrome can change only viewport height. A held
    # pointer and any extra finger must remain quarantined until both lift.
    game.call("_apply_mobile_layout", 390.0, 1, 780.0)
    game.set("jump_left", 0.0)
    game.set("lane", 0)
    game.call("_input", _screen_touch(0, true, Vector2(300, 260)))
    if rotation_gestures.fingers.size() != 1:
        _fail("V64 setup failed to capture a finger before height-only relayout")
        return
    game.call("_apply_mobile_layout", 390.0, 1, 680.0)
    if not rotation_gestures.fingers.is_empty() or not rotation_gestures.blocked_fingers.has(0):
        _fail("V64 height-only relayout must quarantine the held finger")
        return
    game.call("_input", _screen_touch(1, true, Vector2(300, 260)))
    game.call("_input", _screen_drag(1, Vector2(300, 100)))
    game.call("_input", _screen_touch(1, false, Vector2(300, 100)))
    if float(game.get("jump_left")) > 0.0 or int(game.get("lane")) != 0:
        _fail("V64 extra finger during relayout quarantine triggered movement")
        return
    game.call("_input", _screen_drag(0, Vector2(300, 100)))
    game.call("_input", _screen_touch(0, false, Vector2(300, 100)))
    if float(game.get("jump_left")) > 0.0 or not rotation_gestures.blocked_fingers.is_empty():
        _fail("V64 stale finger triggered a jump or remained blocked after release")
        return
    game.call("_input", _screen_touch(0, true, Vector2(300, 260)))
    game.call("_input", _screen_drag(0, Vector2(300, 100)))
    if float(game.get("jump_left")) <= 0.0:
        _fail("V64 new swipe must jump immediately after quarantined touches lift")
        return
    game.call("_input", _screen_touch(0, false, Vector2(300, 100)))
    game.set("jump_left", 0.0)
    # Restore the wide HUD expected by the existing end-to-end race checks.
    game.call("_apply_mobile_layout", 960.0, 0)
    # Training/quiz must ignore all gestures and clear captured touch state.
    game.call("_begin_training")
    var quiz_origin := (game.get("quiz_box") as PanelContainer).get_global_rect().get_center()
    game.set("lane", 0)
    game.set("jump_left", 0.0)
    game.call("_input", _screen_touch(0, true, quiz_origin))
    game.call("_input", _screen_drag(0, quiz_origin + Vector2(190, -140)))
    game.call("_input", _screen_touch(0, false, quiz_origin + Vector2(190, -140)))
    if int(game.get("lane")) != 0 or float(game.get("jump_left")) != 0.0 or not bool(game.get("quiz_active")):
        _fail("Quiz touches leaked into race movement or dismissed the quiz")
        return
    game.call("_start_game")
    game.call("_update_camera", 1.0)
    if portrait_camera.position.z <= 6.0 or portrait_camera.fov < 62.0:
        _fail("Racing must transition back to the playable chase camera")
        return
    var hud := game.get("hud") as Label
    if hud == null or not hud.text.contains("SKYWAY V90") or not hud.text.contains("KOMBO x0"):
        _fail("Race HUD must show the current version and starting combo")
        return
    if not bool(game.get("started")):
        _fail("The race did not start")
        return
    game.call("_shift", 1)
    if int(game.get("lane")) != 1:
        _fail("Player cannot steer to the right")
        return
    game.call("_shift", -1)
    if int(game.get("lane")) != 0:
        _fail("Player cannot steer to the center")
        return
    game.call("_jump")
    if float(game.get("jump_left")) <= 0.0:
        _fail("Jump did not trigger")
        return
    # Regression: repeated turbo taps must not spend energy while boost is active.
    game.set("power", 80)
    game.call("_use_turbo")
    if int(game.get("power")) != 40 or float(game.get("turbo_left")) <= 0.0:
        _fail("Turbo did not activate or charge the expected energy")
        return
    var active_boost: float = float(game.get("turbo_left"))
    game.call("_use_turbo")
    if int(game.get("power")) != 40 or not is_equal_approx(float(game.get("turbo_left")), active_boost):
        _fail("Repeated turbo tap consumed energy or reset the active boost")
        return
    game.set("turbo_left", 0.0)
    game.call("_use_turbo")
    if int(game.get("power")) != 0 or float(game.get("turbo_left")) <= 0.0:
        _fail("Turbo cannot be reactivated after the previous boost expires")
        return
    game.set("turbo_left", 0.0)
    # Energy rings must rotate and pulse without replacing the existing meshes.
    var energy_gate: MeshInstance3D = null
    for item in items.get_children():
        if bool(item.get_meta("energy")):
            energy_gate = item.get_node_or_null("Energy gate") as MeshInstance3D
            break
    if energy_gate == null:
        _fail("Collectible energy gate is missing")
        return
    var previous_angle := energy_gate.rotation.z
    game.set("distance", 14.0)
    game.call("_update_run_items", 0.016)
    if energy_gate.rotation.z <= previous_angle or absf(energy_gate.scale.x - 1.0) < 0.001:
        _fail("Collectible energy gate rotation or pulse is not animated")
        return
    var camera := game.get("chase_camera") as Camera3D
    if camera == null:
        _fail("Chase camera missing")
        return
    game.call("_update_camera", 0.2)
    if camera.fov < 63.0:
        _fail("Camera field of view is invalid")
        return
    game.call("_ask")
    if not bool(game.get("quiz_active")):
        _fail("Vocabulary challenge did not open")
        return
    if game.get("quiz_box") == null:
        _fail("Vocabulary overlay is missing")
        return
    # A child should not receive the same word twice in a row.
    var previous_word: int = int(game.get("correct_index"))
    for attempt in range(20):
        game.call("_ask")
        var current_word: int = int(game.get("correct_index"))
        if current_word == previous_word:
            _fail("Vocabulary challenge repeated the previous word")
            return
        var choices: Array = game.get("options")
        if choices.size() != 3 or not choices.has(current_word):
            _fail("Vocabulary answers are missing the correct translation")
            return
        if choices[0] == choices[1] or choices[0] == choices[2] or choices[1] == choices[2]:
            _fail("Vocabulary challenge contains duplicate answer options")
            return
        previous_word = current_word
    # Cover both the youngest and oldest available grade bands.
    for school_grade in range(1, 11):
        game.set("grade", school_grade)
        game.call("_ask")
        if (game.get("question_label") as Label).text.is_empty():
            _fail("Vocabulary question missing for grade %d" % school_grade)
            return
    # Correct vocabulary answers must update the visible streak counter.
    game.set("grade", 5)
    game.call("_ask")
    var correct_option: int = (game.get("options") as Array).find(int(game.get("correct_index")))
    if correct_option < 0:
        _fail("Correct vocabulary option cannot be selected")
        return
    # An invalid or delayed tap must not crash or change the challenge.
    var before_xp: int = int(game.get("xp"))
    var before_power: int = int(game.get("power"))
    game.call("_answer", -1)
    game.call("_answer", 3)
    if not bool(game.get("quiz_active")) or int(game.get("xp")) != before_xp or int(game.get("power")) != before_power:
        _fail("Invalid quiz answer index modified the active challenge")
        return
    game.call("_answer", correct_option)
    if int(game.get("combo")) != 1 or not hud.text.contains("KOMBO x1"):
        _fail("Correct vocabulary answer does not update the HUD combo")
        return
    # Double tapping a correct answer must never grant a second reward.
    var rewarded_xp: int = int(game.get("xp"))
    var rewarded_power: int = int(game.get("power"))
    game.call("_answer", correct_option)
    if bool(game.get("quiz_active")) or int(game.get("combo")) != 1 or int(game.get("xp")) != rewarded_xp or int(game.get("power")) != rewarded_power:
        _fail("Stale answer awarded vocabulary rewards twice")
        return
    # Wrong answers must reset the visible combo immediately while the quiz
    # is paused; disable only the incorrect choice, not the whole quiz.
    game.call("_ask")
    var next_choices: Array = game.get("options")
    var next_correct: int = int(game.get("correct_index"))
    var wrong_option: int = -1
    for option_index in range(next_choices.size()):
        if int(next_choices[option_index]) != next_correct:
            wrong_option = option_index
            break
    if wrong_option < 0:
        _fail("Could not find an incorrect vocabulary choice")
        return
    game.call("_answer", wrong_option)
    var quiz_buttons: Array = game.get("answer_buttons")
    if not bool(game.get("quiz_active")) or int(game.get("combo")) != 0 or not hud.text.contains("KOMBO x0"):
        _fail("Wrong vocabulary answer did not reset the visible combo")
        return
    if not quiz_buttons[wrong_option].disabled:
        _fail("Wrong vocabulary choice remains tappable")
        return
    game.call("_ask")
    for answer_button in quiz_buttons:
        if answer_button.disabled:
            _fail("A new vocabulary question kept an old answer disabled")
            return
    # V40: the real start flow is tasks -> uninterrupted finite round -> results.
    game.call("_begin_training")
    if str(game.get("phase")) != "training" or not bool(game.get("quiz_active")):
        _fail("Player must solve vocabulary tasks before riding")
        return
    if int(game.get("training_correct")) != 0:
        _fail("Training counter did not reset for a new round")
        return
    for task_index in range(3):
        var task_choices: Array = game.get("options")
        var answer_index: int = task_choices.find(int(game.get("correct_index")))
        if answer_index < 0:
            _fail("Training task has no correct answer")
            return
        game.call("_answer", answer_index)
        if task_index < 2 and (not bool(game.get("quiz_active")) or int(game.get("training_correct")) != task_index + 1):
            _fail("The next training task was not presented")
            return
    if str(game.get("phase")) != "race" or not bool(game.get("started")) or bool(game.get("quiz_active")):
        _fail("Three correct answers did not unlock uninterrupted racing")
        return
    if int(game.get("power")) < 75:
        _fail("Solving tasks did not grant a starting power-up")
        return
    game.set("quiz_time", -999.0)
    game.call("_process", 0.016)
    if bool(game.get("quiz_active")):
        _fail("Race was interrupted by a vocabulary quiz")
        return
    game.set("distance", 799.0)
    game.call("_process", 0.20)
    if str(game.get("phase")) != "results" or bool(game.get("started")):
        _fail("A full 800-meter round did not reach a clear finish")
        return
    if int(game.get("rounds_finished")) != 1 or int(game.get("round_number")) != 2:
        _fail("Winning did not unlock the next round")
        return
    game.call("_begin_training")
    if str(game.get("phase")) != "training" or int(game.get("training_correct")) != 0:
        _fail("The next round must start with fresh vocabulary tasks")
        return
    # V43: the power-up bar must exist without replacing steering controls.
    game.call("_start_game")
    var special_grid := game.get("powerups_grid") as GridContainer
    if special_grid == null or special_grid.get_child_count() != 3:
        _fail("Shield, mega jump and super attack touch buttons are missing")
        return
    var shield_fx := rider.get_node_or_null("Active energy shield") as MeshInstance3D
    var jump_fx := rider.get_node_or_null("Mega jump energy") as MeshInstance3D
    var attack_fx := rider.get_node_or_null("Super attack shockwave") as MeshInstance3D
    if shield_fx == null or jump_fx == null or attack_fx == null:
        _fail("Visible 3D special ability effects are missing")
        return
    # V52: all three powers render detailed curved surfaces, not primitive meshes.
    for effect in [shield_fx, jump_fx, attack_fx]:
        if not (effect.mesh is ArrayMesh) or effect.mesh.get_surface_count() != 1:
            _fail("Ability effect must be a generated 3D ribbon mesh: " + effect.name)
            return
        var material := effect.material_override as StandardMaterial3D
        if material == null or not material.vertex_color_use_as_albedo or not material.emission_enabled:
            _fail("Ability ribbon must preserve shaded gradients and neon emission: " + effect.name)
            return
    if (shield_fx.mesh as ArrayMesh).surface_get_array_len(0) < 6000:
        _fail("Energy shield must use a detailed curved energy dome")
        return
    if (jump_fx.mesh as ArrayMesh).surface_get_array_len(0) < 1100:
        _fail("Mega Jump must use two sculpted rising energy ribbons")
        return
    if (attack_fx.mesh as ArrayMesh).surface_get_array_len(0) < 10000:
        _fail("Super Attack must use three volumetric plasma shockwave rings")
        return
    game.set("power", 100)
    game.call("_use_shield")
    var shield_energy: int = int(game.get("power"))
    if not shield_fx.visible or float(game.get("shield_left")) <= 0.0 or shield_energy != 70:
        _fail("Energy shield activation or cost is incorrect")
        return
    game.call("_use_shield")
    if int(game.get("power")) != shield_energy:
        _fail("Repeated shield button consumed energy")
        return
    var shield_barrier: Node3D = null
    for candidate in items.get_children():
        if not bool(candidate.get_meta("energy")):
            shield_barrier = candidate
            break
    if shield_barrier == null:
        _fail("No obstacle available to test the energy shield")
        return
    shield_barrier.position.x = rider.position.x
    shield_barrier.position.z = rider.position.z - 0.1
    shield_barrier.set_meta("collected", false)
    var lives_before_shield: int = int(game.get("lives"))
    game.call("_update_run_items", 0.02)
    if int(game.get("lives")) != lives_before_shield or not bool(shield_barrier.get_meta("collected")):
        _fail("The shield did not block an obstacle collision")
        return
    game.set("power", 100)
    game.call("_use_mega_jump")
    if int(game.get("power")) != 70 or not jump_fx.visible or not bool(game.get("mega_jump_active")):
        _fail("Mega jump activation or cost is incorrect")
        return
    game.call("_update_run_items", 0.35)
    if rider.position.y < 2.0:
        _fail("Mega jump does not leap higher than a standard jump")
        return
    game.set("power", 100)
    var attack_barrier: Node3D = null
    for candidate in items.get_children():
        if not bool(candidate.get_meta("energy")) and candidate != shield_barrier:
            attack_barrier = candidate
            break
    if attack_barrier == null:
        _fail("No obstacle available to test the super attack")
        return
    attack_barrier.position.z = rider.position.z - 24.0
    attack_barrier.set_meta("collected", false)
    attack_barrier.visible = true
    var before_attack_xp: int = int(game.get("xp"))
    game.call("_use_super_attack")
    if int(game.get("power")) != 55 or not attack_fx.visible:
        _fail("Super attack activation or energy cost is incorrect")
        return
    if not bool(attack_barrier.get_meta("collected")) or attack_barrier.visible or int(game.get("xp")) < before_attack_xp + 20:
        _fail("Super attack did not destroy the forward barrier and award XP")
        return
    game.call("_use_super_attack")
    if int(game.get("power")) != 55:
        _fail("Repeated super attack consumed energy")
        return
    # V43: world selection must change real 3D geometry and the mission goal.
    game.call("_finish_run")
    game.call("_show_world_menu")
    if str(game.get("phase")) != "menu":
        _fail("World selection did not return to the menu")
        return
    game.call("_change_world")
    var canyon := game.get_node_or_null("LearnQuest Crystal Canyon world") as Node3D
    var city := game.get_node_or_null("LearnQuest Skyway world") as Node3D
    if canyon == null or city == null or not canyon.visible or city.visible:
        _fail("Crystal Canyon selection did not switch actual 3D worlds")
        return
    if int(game.get("world_choice")) != 1 or not is_equal_approx(float(game.get("mission_target")), 950.0):
        _fail("Crystal Canyon must have a separate 950-meter mission")
        return
    var rock_mesh: MeshInstance3D = null
    var arch_mesh: MeshInstance3D = null
    for child in canyon.get_children():
        if child.name.begins_with("Canyon rock cluster") and rock_mesh == null:
            rock_mesh = child.get_node_or_null("Sculpted canyon spire") as MeshInstance3D
        if child.name.begins_with("Crystal Canyon sky arch") and arch_mesh == null:
            arch_mesh = child.get_node_or_null("Luminous canyon arch") as MeshInstance3D
    if rock_mesh == null or not (rock_mesh.mesh is ArrayMesh) or (rock_mesh.mesh as ArrayMesh).surface_get_array_len(0) < 150:
        _fail("Crystal Canyon needs sculpted, shaded 3D rock geometry")
        return
    if arch_mesh == null or arch_mesh.mesh == null or not (arch_mesh.material_override as StandardMaterial3D).emission_enabled:
        _fail("Crystal Canyon is missing its luminous 3D gateway")
        return
    var mission_bar := game.get("progress_bar") as ProgressBar
    if mission_bar == null or not is_equal_approx(mission_bar.max_value, 950.0):
        _fail("Mission progress bar does not reflect the selected world")
        return
    game.call("_begin_training")
    game.call("_shift", 1)
    game.call("_use_turbo")
    if int(game.get("lane")) != 0 or float(game.get("turbo_left")) > 0.0:
        _fail("Racing controls must not bypass mandatory vocabulary training")
        return
    for task_index in range(3):
        var choices: Array = game.get("options")
        game.call("_answer", choices.find(int(game.get("correct_index"))))
    if str(game.get("phase")) != "race" or not is_equal_approx(float(game.get("mission_target")), 950.0):
        _fail("Canyon mission did not unlock after three vocabulary answers")
        return
    # V43: sculpted guardian, timed laser warning, shield and boss combat.
    var guardian := game.get_node_or_null("Crystal Guardian Boss") as Node3D
    var beam := game.get("guardian_beam") as MeshInstance3D
    if guardian == null or beam == null:
        _fail("Crystal Guardian boss or laser telegraph is missing")
        return
    var armor := guardian.get_node_or_null("Sculpted guardian armor") as MeshInstance3D
    if armor == null or not (armor.mesh is ArrayMesh) or (armor.mesh as ArrayMesh).surface_get_array_len(0) < 1500:
        _fail("Guardian needs a detailed curved original 3D armor mesh")
        return
    game.set("distance", 600.0)
    game.call("_process", 0.016)
    if not bool(game.get("guardian_active")) or not guardian.visible or int(game.get("guardian_hp")) != 3:
        _fail("Canyon boss did not spawn at the mission midpoint")
        return
    game.set("guardian_attack_timer", 0.0)
    game.call("_process", 0.016)
    if not beam.visible or float(game.get("guardian_warning_left")) <= 0.0:
        _fail("Guardian laser must visibly telegraph before hitting")
        return
    game.set("guardian_lane", int(game.get("lane")))
    beam.position.x = float(game.get("lane")) * 3.1
    game.set("guardian_warning_left", 0.01)
    game.set("shield_left", 2.0)
    var lives_before_laser: int = int(game.get("lives"))
    game.call("_process", 0.02)
    if int(game.get("lives")) != lives_before_laser or beam.visible:
        _fail("Shield did not block guardian laser or clear warning")
        return
    game.set("shield_left", 0.0)
    game.set("guardian_attack_timer", 99.0)
    for hit in range(3):
        game.set("power", 100)
        game.set("attack_left", 0.0)
        game.call("_use_super_attack")
        if int(game.get("guardian_hp")) != 2 - hit:
            _fail("Super Attack did not reduce guardian health")
            return
    if not bool(game.get("guardian_defeated")) or guardian.visible or beam.visible:
        _fail("Guardian boss was not defeated after three attacks")
        return
    game.set("distance", 949.0)
    game.call("_process", 0.15)
    if str(game.get("phase")) != "results" or int(game.get("rounds_finished")) != 2:
        _fail("Canyon mission did not finish at its 950-meter target")
        return
    if int(game.get("total_stars")) < 7 or (game.get("reward_label") as Label).text.find("BONUSSTERN") < 0:
        _fail("Successful missions must award visible stars")
        return
    # V45: third selectable 3D world, original mesh geometry and collection mission.
    game.call("_show_world_menu")
    game.call("_change_world")
    var harbor := game.get_node_or_null("LearnQuest Star Harbor world") as Node3D
    if harbor == null or not harbor.visible or city.visible or canyon.visible:
        _fail("Star Harbor selection must switch actual 3D environments")
        return
    if int(game.get("world_choice")) != 2 or not is_equal_approx(float(game.get("mission_target")), 1100.0):
        _fail("Star Harbor must have an independent 1100-meter mission")
        return
    var tower := harbor.get_node_or_null("Harbor tower cluster 0/Sculpted orbital tower") as MeshInstance3D
    var ship := harbor.get_node_or_null("Harbor tower cluster 0/Sculpted sky freighter") as MeshInstance3D
    var arch := harbor.get_node_or_null("Harbor flight arch 0/Sculpted luminous harbor arch") as MeshInstance3D
    if tower == null or not (tower.mesh is ArrayMesh) or (tower.mesh as ArrayMesh).surface_get_array_len(0) < 700:
        _fail("Sculpted Star Harbor tower geometry missing")
        return
    if ship == null or not (ship.mesh is ArrayMesh) or (ship.mesh as ArrayMesh).surface_get_array_len(0) < 900:
        _fail("Sculpted Star Harbor airship geometry missing")
        return
    if arch == null or not (arch.mesh is ArrayMesh) or (arch.mesh as ArrayMesh).surface_get_array_len(0) < 600:
        _fail("Curved Star Harbor portal geometry missing")
        return
    # V82: landmark-scale orbital carriers are visible, shaded, animated and
    # outside all three lanes; quiz pauses their course without affecting touch.
    var carrier := harbor.get_node_or_null("Cinematic orbital carrier 0") as Node3D
    var second_carrier := harbor.get_node_or_null("Cinematic orbital carrier 1") as Node3D
    var carrier_hull := carrier.get_node_or_null("Armored carrier fuselage") as MeshInstance3D if carrier != null else null
    var canopy := carrier.get_node_or_null("Panoramic command canopy") as MeshInstance3D if carrier != null else null
    var gyro := carrier.get_node_or_null("Animated docking gyroscope 0") as Node3D if carrier != null else null
    var torus := gyro.get_node_or_null("Sculpted rotating energy torus") as MeshInstance3D if gyro != null else null
    var exhaust := carrier.get_node_or_null("Pulsing ion exhaust 0") as MeshInstance3D if carrier != null else null
    var carrier_light := carrier.get_node_or_null("Carrier cinematic engine light") as OmniLight3D if carrier != null else null
    if carrier == null or second_carrier == null or carrier_hull == null or not (carrier_hull.mesh is SphereMesh):
        _fail("V82 Star Harbor must contain two shaded 3D orbital carrier hulls")
        return
    if canopy == null or not (canopy.material_override is StandardMaterial3D) or (canopy.material_override as StandardMaterial3D).transparency != BaseMaterial3D.TRANSPARENCY_ALPHA:
        _fail("V82 orbital carrier panoramic canopy must have real translucent glass")
        return
    if gyro == null or torus == null or not (torus.mesh is TorusMesh) or exhaust == null or carrier_light == null:
        _fail("V82 orbital carriers need gyroscopes, ion exhaust and cinematic lighting")
        return
    if absf(carrier.position.x) - 5.8 < 9.0 or carrier.position.y < 10.0 or absf(second_carrier.position.x) - 5.8 < 9.0:
        _fail("V82 orbital carriers must remain clear of the rider and race lanes")
        return
    if carrier.find_children("*", "CollisionObject3D", true, false).size() != 0:
        _fail("V82 scenic orbital carrier must not create player collisions")
        return
    var carrier_z := carrier.position.z
    var gyro_rotation := gyro.rotation.y
    var exhaust_scale := exhaust.scale.x
    harbor.set("running", true)
    harbor.call("_process", 0.31)
    if carrier.position.z <= carrier_z or is_equal_approx(gyro.rotation.y, gyro_rotation) or is_equal_approx(exhaust.scale.x, exhaust_scale):
        _fail("V82 orbital carrier flight, ring rotation or ion animation is broken")
        return
    harbor.set("running", false)
    var paused_carrier_z := carrier.position.z
    harbor.call("_process", 0.31)
    if not is_equal_approx(carrier.position.z, paused_carrier_z):
        _fail("V82 orbital carriers must stop moving through the course during quizzes")
        return
    game.call("_begin_training")
    for task_index in range(3):
        var harbor_choices: Array = game.get("options")
        game.call("_answer", harbor_choices.find(int(game.get("correct_index"))))
    if str(game.get("phase")) != "race" or int(game.get("harbor_crystals")) != 0:
        _fail("Star Harbor must begin only after three vocabulary answers")
        return
    var energy_item: Node3D = null
    for candidate in items.get_children():
        if bool(candidate.get_meta("energy")):
            energy_item = candidate
            break
    if energy_item == null:
        _fail("No collectible energy gate for Star Harbor mission")
        return
    for crystal in range(4):
        energy_item.position.x = rider.position.x
        energy_item.position.z = rider.position.z - 0.10
        energy_item.set_meta("collected", false)
        game.call("_update_run_items", 0.02)
    game.call("_refresh_hud")
    if int(game.get("harbor_crystals")) != 4 or not hud.text.contains("HAFEN-MISSION"):
        _fail("Star Harbor crystal collection is not reflected in mission HUD")
        return
    # V46: a second, independently animated boss must be real 3D geometry
    # with a fair visible plasma telegraph, distinct turbo behavior and rewards.
    var sentinel := game.get_node_or_null("Star Harbor Orbit Sentinel Boss") as Node3D
    var plasma := game.get("orbit_beam") as MeshInstance3D
    if sentinel == null or plasma == null:
        _fail("Star Harbor sentinel boss or visible plasma warning is missing")
        return
    var sentinel_hull := sentinel.get_node_or_null("Sculpted sentinel hull") as MeshInstance3D
    var sentinel_wing := sentinel.get_node_or_null("Articulated wing left/Curved flight wing") as MeshInstance3D
    if sentinel_hull == null or not (sentinel_hull.mesh is ArrayMesh) or (sentinel_hull.mesh as ArrayMesh).surface_get_array_len(0) < 3000:
        _fail("Orbit sentinel must use a large sculpted, shaded hull")
        return
    if sentinel_wing == null or not (sentinel_wing.mesh is ArrayMesh) or (sentinel_wing.mesh as ArrayMesh).surface_get_array_len(0) < 1300:
        _fail("Orbit sentinel must have detailed curved animated wings")
        return
    game.set("distance", 700.0)
    game.set("hit_cooldown", 2.0)
    game.call("_process", 0.016)
    if not bool(game.get("orbit_active")) or not sentinel.visible or int(game.get("orbit_hp")) != 2:
        _fail("Star Harbor boss did not spawn in the second half of the race")
        return
    var orbital_rings := sentinel.get_node_or_null("Animated orbital rings") as Node3D
    var old_orbit_angle: float = orbital_rings.rotation.y
    sentinel.call("_process", 0.25)
    if is_equal_approx(old_orbit_angle, orbital_rings.rotation.y):
        _fail("Star Harbor boss energy rings do not animate")
        return
    game.set("orbit_attack_timer", 0.0)
    game.call("_update_orbit_sentinel", 0.016)
    if not plasma.visible or float(game.get("orbit_warning_left")) <= 0.0:
        _fail("Orbit Sentinel must warn before firing plasma")
        return
    game.set("hit_cooldown", 0.0)
    game.set("shield_left", 0.0)
    game.set("turbo_left", 2.0)
    rider.position.y = 0.0
    var lives_before_plasma: int = int(game.get("lives"))
    game.set("orbit_warning_left", 0.01)
    game.call("_update_orbit_sentinel", 0.02)
    if int(game.get("lives")) != lives_before_plasma - 1 or plasma.visible:
        _fail("Orbit plasma must damage an unshielded rider despite Turbo")
        return
    game.set("orbit_attack_timer", 0.0)
    game.call("_update_orbit_sentinel", 0.016)
    game.set("shield_left", 2.0)
    game.set("hit_cooldown", 0.0)
    var lives_before_block: int = int(game.get("lives"))
    game.set("orbit_warning_left", 0.01)
    game.call("_update_orbit_sentinel", 0.02)
    if int(game.get("lives")) != lives_before_block or plasma.visible:
        _fail("Energy Shield must block the Orbit Sentinel plasma blast")
        return
    for hit in range(2):
        game.set("power", 100)
        game.set("attack_left", 0.0)
        game.call("_use_super_attack")
        if int(game.get("orbit_hp")) != 1 - hit:
            _fail("Super Attack did not reduce Orbit Sentinel health")
            return
    if not bool(game.get("orbit_defeated")) or sentinel.visible or plasma.visible:
        _fail("Orbit Sentinel was not defeated after two Super Attacks")
        return
    game.set("distance", 1099.0)
    game.call("_process", 0.15)
    if str(game.get("phase")) != "results" or int(game.get("rounds_finished")) != 3:
        _fail("Star Harbor mission did not reach its finish")
        return
    if (game.get("reward_label") as Label).text.find("HAFEN-MISSION ERFÜLLT") < 0:
        _fail("Star Harbor crystal mission did not grant a bonus star")
        return
    # V45: fourth real 3D world with sculpted ice, translucent aurora and
    # skill-based airborne gate mission. No paid or third-party assets.
    game.call("_show_world_menu")
    game.call("_change_world")
    var glacier := game.get_node_or_null("LearnQuest Aurora Glacier world") as Node3D
    if glacier == null or not glacier.visible or city.visible or canyon.visible or harbor.visible:
        _fail("Aurora Glacier selection must switch to the fourth actual 3D world")
        return
    if int(game.get("world_choice")) != 3 or not is_equal_approx(float(game.get("mission_target")), 1200.0):
        _fail("Aurora Glacier must have an independent 1200-meter mission")
        return
    var ridge := glacier.get_node_or_null("Glacier ridge cluster 0/Sculpted ice ridge") as MeshInstance3D
    var ice_arch := glacier.get_node_or_null("Sculpted ice arch 0/Continuous sculpted ice arch") as MeshInstance3D
    var silk := glacier.get_node_or_null("Aurora silk 0") as MeshInstance3D
    var jump_ring := glacier.get_node_or_null("Aurora jump gate 0/Sculpted jump ring") as MeshInstance3D
    if ridge == null or not (ridge.mesh is ArrayMesh) or (ridge.mesh as ArrayMesh).surface_get_array_len(0) < 700:
        _fail("Glacier ridges must be sculpted and vertex shaded")
        return
    if ice_arch == null or not (ice_arch.mesh is ArrayMesh) or (ice_arch.mesh as ArrayMesh).surface_get_array_len(0) < 2000:
        _fail("Glacier needs continuous sculpted ice arch geometry")
        return
    if silk == null or not (silk.mesh is ArrayMesh) or (silk.mesh as ArrayMesh).surface_get_array_len(0) < 1500:
        _fail("Aurora ribbons must use a detailed original 3D surface mesh")
        return
    var aurora_material := silk.material_override as StandardMaterial3D
    if aurora_material == null or aurora_material.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA or not aurora_material.vertex_color_use_as_albedo:
        _fail("Aurora must preserve translucent vertex-color gradients")
        return
    if jump_ring == null or not (jump_ring.mesh is ArrayMesh) or (jump_ring.mesh as ArrayMesh).surface_get_array_len(0) < 2500:
        _fail("Airborne mission gate must be a sculpted 3D ring")
        return
    var silk_angle: float = silk.rotation.z
    glacier.call("_process", 0.8)
    if is_equal_approx(silk.rotation.z, silk_angle):
        _fail("Aurora sky ribbons do not animate")
        return
    # V86: cinematic Aurora crystal sentinels are real faceted 3D objects,
    # animated without physics and kept outside the playable lanes.
    var aurora_sentinels := glacier.get_node_or_null("Cinematic Aurora crystal sentinels") as Node3D
    if aurora_sentinels == null:
        _fail("V86 Aurora crystal sentinels are missing")
        return
    var aurora_monuments: Array = aurora_sentinels.get("monuments")
    if aurora_monuments.size() != 4:
        _fail("V86 Aurora needs four monumental animated crystals")
        return
    var aurora_first := aurora_sentinels.get_node_or_null("Crystal sentinel 0") as Node3D
    var aurora_gem := aurora_sentinels.get_node_or_null("Crystal sentinel 0/Floating crystal core/Shaded faceted aurora gem") as MeshInstance3D
    var aurora_halo := aurora_sentinels.get_node_or_null("Crystal sentinel 0/Outer rotating aurora halo/Curved translucent energy ring") as MeshInstance3D
    var aurora_shard := aurora_sentinels.get_node_or_null("Crystal sentinel 0/Orbiting crystal shards/Satellite shard 0") as MeshInstance3D
    var aurora_light := aurora_sentinels.get_node_or_null("Crystal sentinel 0/Soft aurora sentinel light") as OmniLight3D
    if aurora_first == null or aurora_gem == null or aurora_halo == null or aurora_shard == null or aurora_light == null:
        _fail("V86 Aurora crystal models, animated rings, satellites or light are missing")
        return
    if not (aurora_gem.mesh is ArrayMesh) or (aurora_gem.mesh as ArrayMesh).surface_get_array_len(0) < 200:
        _fail("V86 Aurora crystals need original shaded faceted 3D geometry")
        return
    if not (aurora_halo.mesh is ArrayMesh) or (aurora_halo.mesh as ArrayMesh).surface_get_array_len(0) < 2000:
        _fail("V86 Aurora rings need curved, detailed 3D geometry")
        return
    var aurora_halo_material := aurora_halo.material_override as StandardMaterial3D
    if aurora_halo_material == null or aurora_halo_material.transparency != BaseMaterial3D.TRANSPARENCY_ALPHA or not aurora_halo_material.vertex_color_use_as_albedo:
        _fail("V86 Aurora rings need translucent vertex-colored material")
        return
    for monument in aurora_monuments:
        if absf((monument as Node3D).position.x) < 10.0 or (monument as Node3D).find_children("*", "CollisionObject3D", true, false).size() > 0:
            _fail("V86 Aurora monuments must stay outside the lanes without collisions")
            return
    var aurora_start_z: float = aurora_first.position.z
    var aurora_start_angle: float = (aurora_halo.get_parent() as Node3D).rotation.z
    aurora_sentinels.set("running", false)
    aurora_sentinels.call("_process", 0.6)
    if not is_equal_approx(aurora_first.position.z, aurora_start_z):
        _fail("V86 Aurora crystal architecture must not travel during quizzes")
        return
    aurora_sentinels.set("running", true)
    aurora_sentinels.set("travel_speed", 14.0)
    aurora_sentinels.call("_process", 0.6)
    if aurora_first.position.z <= aurora_start_z or is_equal_approx((aurora_halo.get_parent() as Node3D).rotation.z, aurora_start_angle):
        _fail("V86 Aurora crystals must travel and animate their rings during races")
        return
    aurora_first.position.z = aurora_start_z
    aurora_sentinels.set("running", false)
    game.call("_begin_training")
    game.call("_shift", 1)
    game.call("_use_turbo")
    if int(game.get("lane")) != 0 or float(game.get("turbo_left")) > 0.0:
        _fail("Glacier controls bypassed the mandatory vocabulary tasks")
        return
    for task_index in range(3):
        var glacier_choices: Array = game.get("options")
        game.call("_answer", glacier_choices.find(int(game.get("correct_index"))))
    if str(game.get("phase")) != "race" or int(glacier.get("completed_gates")) != 0:
        _fail("Glacier mission must start only after three correct answers")
        return
    var gates: Array = glacier.get("jump_gates")
    if gates.size() != 5:
        _fail("Aurora Glacier must have five real skill-based jump gates")
        return
    for gate_index in range(3):
        var mission_gate := gates[gate_index] as Node3D
        mission_gate.position.z = 0.3
        rider.position.x = mission_gate.position.x
        rider.position.y = 1.4
        game.call("_update_glacier_mission")
    if int(glacier.get("completed_gates")) != 3 or not hud.text.contains("AURORA-SPRUNGTORE"):
        game.call("_refresh_hud")
        if int(glacier.get("completed_gates")) != 3 or not hud.text.contains("AURORA-SPRUNGTORE"):
            _fail("Three actual steering-and-jump gates did not score the mission")
            return
    var missed_gate := gates[3] as Node3D
    missed_gate.position.z = 0.3
    rider.position.y = 0.0
    rider.position.x = missed_gate.position.x
    game.call("_update_glacier_mission")
    game.call("_update_glacier_mission")
    if int(glacier.get("missed_gates")) != 1 or int(glacier.get("completed_gates")) != 3:
        _fail("Missed jump gates must score only once and never grant rewards")
        return
    # V47: sculpted Aurora frost dragon, two warned lanes and a safe escape.
    var frost := game.get_node_or_null("Aurora Frost Warden Boss") as Node3D
    if frost == null:
        _fail("Aurora frost dragon boss is missing")
        return
    var frost_body := frost.get_node_or_null("Sculpted frost dragon body") as MeshInstance3D
    var frost_fin := frost.get_node_or_null("Animated frost fin left/Curved ice fin") as MeshInstance3D
    var frost_jaw := frost.get_node_or_null("Articulated frost jaw") as Node3D
    if frost_body == null or not (frost_body.mesh is ArrayMesh) or (frost_body.mesh as ArrayMesh).surface_get_array_len(0) < 6000:
        _fail("Frost dragon needs a large, shaded original body mesh")
        return
    if frost_fin == null or not (frost_fin.mesh is ArrayMesh) or (frost_fin.mesh as ArrayMesh).surface_get_array_len(0) < 1300 or frost_jaw == null:
        _fail("Frost dragon needs curved animated fins and a jaw")
        return
    game.set("distance", 900.0)
    game.set("hit_cooldown", 2.0)
    game.call("_process", 0.016)
    if not bool(game.get("frost_active")) or not frost.visible or int(game.get("frost_hp")) != 3:
        _fail("Aurora boss did not spawn during the second half of the race")
        return
    var jaw_angle: float = frost_jaw.rotation.x
    frost.call("_process", 0.4)
    if is_equal_approx(frost_jaw.rotation.x, jaw_angle):
        _fail("Frost dragon jaw does not animate")
        return
    game.set("frost_attack_timer", 0.0)
    game.call("_update_frost_warden", 0.016)
    var ice_waves: Array = game.get("frost_warnings")
    if ice_waves.size() != 2 or not ice_waves[0].visible or not ice_waves[1].visible:
        _fail("Frost dragon must telegraph two dangerous lanes")
        return
    # V52: the warning is a shaded, animated two-surface ice wave, not a box.
    for wave in ice_waves:
        if not (wave.mesh is ArrayMesh) or wave.mesh.get_surface_count() != 2:
            _fail("Aurora warning must use a sculpted two-surface ice mesh")
            return
        if wave.mesh.surface_get_array_len(0) < 3000:
            _fail("Aurora shockwave is missing its detailed curved ice surface")
            return
        if wave.mesh.surface_get_material(1) == null:
            _fail("Aurora shockwave crest needs a visible material")
            return
    var wave_y_before: float = ice_waves[0].position.y
    var wave_x_before: float = ice_waves[0].position.x
    ice_waves[0].call("_process", 0.25)
    if is_equal_approx(ice_waves[0].position.y, wave_y_before) or not is_equal_approx(ice_waves[0].position.x, wave_x_before):
        _fail("Frost warning must animate without changing the targeted lane")
        return
    var safe_lane: int = int(game.get("frost_safe_lane"))
    var danger_lane: int = int(roundf(ice_waves[0].position.x / 3.1))
    if danger_lane == safe_lane or is_equal_approx(ice_waves[0].position.x, ice_waves[1].position.x):
        _fail("Frost shockwave must leave a distinct safe lane")
        return
    game.set("lane", danger_lane)
    rider.position.y = 0.0
    game.set("shield_left", 0.0)
    game.set("hit_cooldown", 0.0)
    var lives_before_ice: int = int(game.get("lives"))
    game.set("frost_warning_left", 0.01)
    game.call("_update_frost_warden", 0.02)
    if int(game.get("lives")) != lives_before_ice - 1 or ice_waves[0].visible or ice_waves[1].visible:
        _fail("Unshielded rider in frost lane must take one hit")
        return
    game.set("frost_attack_timer", 0.0)
    game.call("_update_frost_warden", 0.016)
    game.set("lane", int(roundf(ice_waves[0].position.x / 3.1)))
    game.set("shield_left", 2.0)
    game.set("hit_cooldown", 0.0)
    var lives_before_ice_shield: int = int(game.get("lives"))
    game.set("frost_warning_left", 0.01)
    game.call("_update_frost_warden", 0.02)
    if int(game.get("lives")) != lives_before_ice_shield:
        _fail("Shield must block frost shockwave")
        return
    game.set("frost_attack_timer", 0.0)
    game.call("_update_frost_warden", 0.016)
    game.set("lane", int(game.get("frost_safe_lane")))
    game.set("shield_left", 0.0)
    game.set("hit_cooldown", 0.0)
    var lives_before_safe: int = int(game.get("lives"))
    game.set("frost_warning_left", 0.01)
    game.call("_update_frost_warden", 0.02)
    if int(game.get("lives")) != lives_before_safe:
        _fail("Unmarked third lane must remain safe")
        return
    for hit in range(3):
        game.set("power", 100)
        game.set("attack_left", 0.0)
        game.call("_use_super_attack")
        if int(game.get("frost_hp")) != 2 - hit:
            _fail("Super Attack did not damage Aurora boss")
            return
    if not bool(game.get("frost_defeated")) or frost.visible or ice_waves[0].visible or ice_waves[1].visible:
        _fail("Three attacks must defeat Aurora boss and clear warnings")
        return
    game.set("distance", 1199.0)
    game.call("_process", 0.2)
    if str(game.get("phase")) != "results" or int(game.get("rounds_finished")) != 4:
        _fail("Aurora Glacier did not finish at its 1200-meter target")
        return
    if (game.get("reward_label") as Label).text.find("AURORA-SPRUNG-MISSION") < 0:
        _fail("Glacier airborne mission did not grant its bonus star")
        return
    if (game.get("reward_label") as Label).text.find("FROST-DRACHE BESIEGT") < 0:
        _fail("Defeating Aurora boss must grant an additional bonus star")
        return
    game.call("_show_world_menu")
    game.call("_change_world")
    if int(game.get("world_choice")) != 0 or not city.visible or canyon.visible or harbor.visible or glacier.visible:
        _fail("Switching back to Neon City did not restore its 3D environment")
        return
    print("LEARNQUEST SMOKE TEST PASSED: 4 worlds, animated sculpted ice waves, Aurora Glacier and frost dragon, orbital sentinel and guardian combat, airborne gates, vocabulary grades 1-10, powers and uninterrupted rounds")
    quit(0)
