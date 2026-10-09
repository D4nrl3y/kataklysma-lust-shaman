extends SceneTree

const CombatScript = preload("res://03_GODOT/scripts/combat_system.gd")

var failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var combat: Variant = CombatScript.new()
	var snapshot: Dictionary = combat.start_battle("corrupted_makrura", true, {
		"spirit_helped": true,
		"analysis_done": false,
		"attributes": {"agility": 80, "stamina": 100, "intellect": 80, "spirit": 75},
	})
	_expect(int(snapshot.get("boss_phase", 0)) == 1, "Makrura begins in phase one")
	_expect(snapshot.get("actions", []).has("terrain"), "boss exposes arena interaction")

	combat.perform_action("strike")
	snapshot = combat.perform_action("strike")
	_expect(_events_contain(snapshot, "Descarga das poças condutivas"), "ungrounded conductive pool hazard damages Kataklysma")
	snapshot = combat.perform_action("terrain")
	_expect(bool(snapshot.get("enemy", {}).get("conductive_grounded", false)), "arena grounding disables the phase-one hazard")
	_run_phase_until_change(combat, 1)
	snapshot = combat.get_snapshot()
	_expect(int(snapshot.get("boss_phase", 0)) == 2, "phase-one defeat transitions into phase two")
	_expect(_events_contain(snapshot, "breve respiro"), "phase transition provides bounded recovery")
	_expect(not bool(snapshot.get("enemy", {}).get("eggs_cleared", true)), "phase two begins with eggs active")

	snapshot = combat.perform_action("strike")
	_expect(_events_contain(snapshot, "ovos restauram 8 HP"), "active eggs regenerate the boss during its turn")
	snapshot = combat.perform_action("terrain")
	_expect(bool(snapshot.get("enemy", {}).get("eggs_cleared", false)), "arena interaction clears the eggs")
	_run_phase_until_change(combat, 2)
	snapshot = combat.get_snapshot()
	_expect(int(snapshot.get("boss_phase", 0)) == 3, "phase-two defeat transitions into phase three")
	_expect(bool(snapshot.get("enemy", {}).get("ritual_stone_active", false)), "phase three begins with ritual stone active")

	snapshot = combat.perform_action("strike")
	_expect(_events_contain(snapshot, "pedra ritual acrescenta 1 corrupção"), "active ritual stone increases corruption")
	snapshot = combat.perform_action("terrain")
	_expect(not bool(snapshot.get("enemy", {}).get("ritual_stone_active", true)), "arena interaction interrupts the ritual stone")
	_run_phase_until_change(combat, 3)
	snapshot = combat.get_snapshot()
	_expect(str(snapshot.get("result", "")) == "victory", "third-phase defeat ends the boss battle")
	_expect(int(snapshot.get("boss_phase", 0)) == 3, "battle records all three phases")

	if failures.is_empty():
		print("MAKRURA_BOSS_TEST: PASS (three combat phases and arena mechanics)")
		quit(0)
	else:
		push_error("MAKRURA_BOSS_TEST: %d checks failed: %s" % [failures.size(), ", ".join(failures)])
		quit(1)


func _run_phase_until_change(combat: Variant, expected_phase: int) -> void:
	for _turn in 80:
		var snapshot: Dictionary = combat.get_snapshot()
		if int(snapshot.get("boss_phase", 0)) != expected_phase or str(snapshot.get("phase", "")) in ["victory", "defeat"]:
			return
		if str(snapshot.get("phase", "")) != "player_turn":
			_fail("combat did not return to the player turn")
			return
		combat.perform_action(_choose_survival_action(snapshot))
	_fail("boss phase %d did not resolve within the turn limit" % expected_phase)


func _choose_survival_action(snapshot: Dictionary) -> String:
	var player_stats: Dictionary = snapshot.get("player", {})
	var hp := int(player_stats.get("hp", 0))
	var max_hp := int(player_stats.get("max_hp", 1))
	var spirit := int(player_stats.get("spirit", 0))
	if hp * 100 <= max_hp * 78 and spirit >= 25:
		return "purify"
	if spirit >= 18:
		return "channel"
	return "strike"


func _events_contain(snapshot: Dictionary, needle: String) -> bool:
	for event_value in snapshot.get("events", []):
		if str(event_value).contains(needle):
			return true
	return false


func _expect(condition: bool, label: String) -> void:
	if not condition:
		_fail(label)


func _fail(label: String) -> void:
	failures.append(label)
	push_error("MAKRURA_BOSS_TEST: FAIL | %s" % label)
