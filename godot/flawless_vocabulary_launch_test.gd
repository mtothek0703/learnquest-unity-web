extends SceneTree
## Real scene-level regression: three mandatory English answers gate the race.
## A clean 3/3 awards a launch Turbo; any wrong attempt forfeits that bonus.
func _initialize() -> void:
    call_deferred("_check")

func _fail(message: String) -> void:
    push_error("FLAWLESS VOCABULARY LAUNCH TEST FAILED: " + message)
    quit(1)

func _correct(game: Node3D) -> bool:
    var choices: Array = game.get("options")
    var answer: int = choices.find(int(game.get("correct_index")))
    if answer < 0:
        _fail("correct answer not present among the three quiz options")
        return false
    game.call("_answer", answer)
    return true

func _check() -> void:
    var game := (load("res://main.tscn") as PackedScene).instantiate() as Node3D
    root.add_child(game)
    await process_frame
    game.call("_begin_training")
    if str(game.get("phase")) != "training" or not bool(game.get("quiz_active")):
        _fail("the first race must start with mandatory vocabulary questions")
        return
    for step in range(3):
        if not _correct(game):
            return
        if step < 2 and (str(game.get("phase")) != "training" or \
                int(game.get("training_correct")) != step + 1):
            _fail("a full race started before three correct English answers")
            return
    if str(game.get("phase")) != "race" or bool(game.get("quiz_active")) or \
            not bool(game.get("flawless_vocabulary_launch")):
        _fail("three flawless answers must unlock an uninterrupted race")
        return
    if int(game.get("xp")) != 165 or int(game.get("power")) != 75 or \
            absf(float(game.get("turbo_left")) - 2.5) > 0.001:
        _fail("flawless launch must grant exactly +60 XP and 2.5s Turbo")
        return
    if not (game.get("info_label") as Label).text.contains("WORT-MEISTER"):
        _fail("the clean start needs visible on-screen feedback")
        return
    game.set("distance", float(game.get("mission_target")))
    game.call("_finish_run")
    if not (game.get("reward_label") as Label).text.contains("WORT-MEISTER"):
        _fail("flawless achievement must appear on the result screen")
        return
    game.call("_begin_training")
    if int(game.get("training_mistakes")) != 0 or \
            bool(game.get("flawless_vocabulary_launch")) or \
            float(game.get("turbo_left")) != 0.0:
        _fail("a new round must reset flawless progress and the old Turbo")
        return
    var choices: Array = game.get("options")
    var wrong: int = -1
    for i in range(choices.size()):
        if int(choices[i]) != int(game.get("correct_index")):
            wrong = i
            break
    if wrong < 0:
        _fail("quiz lacks a wrong answer to exercise the retry path")
        return
    game.call("_answer", wrong)
    game.call("_answer", wrong)
    if int(game.get("training_mistakes")) != 1 or \
            not (game.get("answer_buttons") as Array)[wrong].disabled:
        _fail("a disabled wrong answer must not count twice")
        return
    for step in range(3):
        if not _correct(game):
            return
    if str(game.get("phase")) != "race" or bool(game.get("flawless_vocabulary_launch")):
        _fail("a corrected mistake must allow the race without the clean bonus")
        return
    if int(game.get("xp")) != 105 or float(game.get("turbo_left")) != 0.0 or \
            int(game.get("power")) != 75:
        _fail("ordinary three-question run must retain the original rewards")
        return
    print("FLAWLESS VOCABULARY LAUNCH TEST PASSED: clean 3/3, wrong retry, reset, race and results")
    quit(0)
