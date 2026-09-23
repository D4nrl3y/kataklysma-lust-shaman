extends SceneTree

var failures: Array[String] = []

func _init() -> void:
    call_deferred("_run")

func _run() -> void:
    var demo = load("res://03_GODOT/scenes/main.tscn").instantiate()
    root.add_child(demo)
    await process_frame
    demo.audio_manager.enabled = false
    demo._start_new_game()

    var escape_checks: Array = [
        ["costa oeste", Vector2(120.0, 450.0), false],
        ["costa sul", Vector2(500.0, 820.0), false],
        ["costa leste", Vector2(1600.0, 600.0), false],
        ["waterfall", Vector2(175.0, 320.0), false],
        ["cliffs arena", Vector2(700.0, 220.0), false],
        ["bordas cabana", Vector2(100.0, 220.0), false],
        ["vegetação norte", Vector2(730.0, 110.0), false],
        ["região Zek'Ranu", demo.NPC_POSITION, true],
        ["ponte", Vector2(1450.0, 350.0), true],
        ["plataforma totens", Vector2(1300.0, 150.0), true],
        ["ilhas menores", Vector2(900.0, 750.0), false],
        ["pedras centrais", Vector2(575.0, 380.0), false],
        ["escadas", Vector2(450.0, 350.0), true],
        ["bifurcação estreita", Vector2(700.0, 390.0), true],
        ["extremidade mapa", Vector2(20.0, 450.0), false],
    ]
    for check in escape_checks:
        var label: String = check[0]
        var position: Vector2 = check[1]
        var expected_walkable: bool = check[2]
        var actual_walkable: bool = bool(demo._is_walkable_position(position))
        var passed := actual_walkable == expected_walkable
        print("WALKABILITY_QA | %s | %s" % [label, "PASS" if passed else "FAIL"])
        if not passed:
            failures.append(label)

    var physical_checks: Array = [
        ["água oeste", Vector2(250.0, 760.0)],
        ["água sul", Vector2(760.0, 820.0)],
        ["água leste", Vector2(1600.0, 600.0)],
        ["cliff arena", Vector2(640.0, 250.0)],
        ["pedras centrais", Vector2(575.0, 380.0)],
        ["vegetação norte", Vector2(730.0, 110.0)],
        ["limite mapa", Vector2(20.0, 450.0)],
    ]
    for check in physical_checks:
        var label: String = check[0]
        var target: Vector2 = check[1]
        var passed: bool = bool(demo.collision_probe_for_test(demo.PLAYER_START, target))
        print("BLOCKER_QA | %s | %s" % [label, "PASS" if passed else "FAIL"])
        if not passed:
            failures.append("blocker " + label)

    if failures.is_empty():
        print("FINAL_RELEASE_QA: PASS")
    else:
        print("FINAL_RELEASE_QA: FAIL -> %s" % ", ".join(failures))
    demo.audio_manager.free()
    demo.free()
    quit(0 if failures.is_empty() else 1)
