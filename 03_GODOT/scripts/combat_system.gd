class_name KataklysmaCombatSystem
extends RefCounted

## Deterministic, data-driven turn combat for the first playable slice.
## The UI is kept outside this class so the rules can later be reused by
## quests, bosses and a dedicated battle scene.

const ACTIONS := ["strike", "channel", "guard", "purify", "flee"]
const SPIRIT_CHANNEL_COST := 18
const SPIRIT_PURIFY_COST := 25

var rng := RandomNumberGenerator.new()
var player: Dictionary = {}
var enemy: Dictionary = {}
var phase := "idle"
var round := 0
var battle_result := ""
var _events: Array[String] = []
var _action_consumed := false

func _init() -> void:
    rng.seed = 1337

func start_battle(enemy_id: String = "corrupted_makrura") -> Dictionary:
    player = {
        "id": "kataklysma",
        "display_name": "Kataklysma",
        "max_hp": 120,
        "hp": 120,
        "max_spirit": 100,
        "spirit": 72,
        "power": 23,
        "spell_power": 29,
        "defense": 9,
        "spirit_defense": 10,
        "agility": 15,
        "guard": false,
        "corruption": 0,
    }
    enemy = _build_enemy(enemy_id)
    phase = "player_turn"
    round = 1
    battle_result = ""
    _events.clear()
    _append_event("Round 1 — sua vez.")
    return get_snapshot()

func _build_enemy(enemy_id: String) -> Dictionary:
    if enemy_id == "water_spirit_weakened":
        return {
            "id": enemy_id,
            "display_name": "Espírito da Água Enfraquecido",
            "max_hp": 92,
            "hp": 92,
            "power": 18,
            "spell_power": 22,
            "defense": 6,
            "spirit_defense": 8,
            "agility": 13,
            "guard": false,
            "corruption": 0,
        }
    return {
        "id": "corrupted_makrura",
        "display_name": "Makrura Corrompida",
        "max_hp": 108,
        "hp": 108,
        "power": 21,
        "spell_power": 19,
        "defense": 8,
        "spirit_defense": 7,
        "agility": 12,
        "guard": false,
        "corruption": 0,
    }

func get_snapshot() -> Dictionary:
    return {
        "phase": phase,
        "round": round,
        "result": battle_result,
        "player": player.duplicate(true),
        "enemy": enemy.duplicate(true),
        "events": _events.duplicate(),
        "actions": ACTIONS.duplicate(),
    }

func perform_action(action: String) -> Dictionary:
    _events.clear()
    _action_consumed = true
    if phase != "player_turn":
        _append_event("Aguarde: não é o seu turno.")
        return get_snapshot()
    if not ACTIONS.has(action):
        _append_event("Ação desconhecida.")
        return get_snapshot()

    match action:
        "strike":
            _player_strike()
        "channel":
            _player_channel()
        "guard":
            _player_guard()
        "purify":
            _player_purify()
        "flee":
            _player_flee()

    if not _action_consumed:
        return get_snapshot()
    if phase != "player_turn":
        return get_snapshot()
    if int(enemy.get("hp", 0)) <= 0:
        _finish("victory", "A ameaça foi derrotada.")
        return get_snapshot()

    phase = "enemy_turn"
    _enemy_turn()
    if int(player.get("hp", 0)) <= 0:
        _finish("defeat", "Kataklysma caiu em combate.")
        return get_snapshot()
    round += 1
    phase = "player_turn"
    _apply_player_start_turn()
    if int(player.get("hp", 0)) <= 0:
        _finish("defeat", "A corrupção drenou suas forças.")
    elif phase == "player_turn":
        _append_event("Round %d — sua vez." % round)
    return get_snapshot()

func _player_strike() -> void:
    var hit_roll: float = rng.randf()
    if hit_roll > 0.9:
        _append_event("Kataklysma errou o ataque físico.")
        return
    var critical: bool = hit_roll < 0.1
    var raw_damage: int = int(player["power"]) + rng.randi_range(-3, 4)
    if critical:
        raw_damage *= 2
    var damage: int = _deal_damage(enemy, raw_damage, "defense")
    _append_event("Ataque físico%s causou %d de dano." % [" crítico" if critical else "", damage])

func _player_channel() -> void:
    if int(player["spirit"]) < SPIRIT_CHANNEL_COST:
        _append_event("Espírito insuficiente: são necessários %d." % SPIRIT_CHANNEL_COST)
        _action_consumed = false
        return
    player["spirit"] = int(player["spirit"]) - SPIRIT_CHANNEL_COST
    var raw_damage: int = int(player["spell_power"]) + rng.randi_range(3, 9)
    var damage: int = _deal_damage(enemy, raw_damage, "spirit_defense")
    enemy["corruption"] = max(0, int(enemy["corruption"]) - 1)
    _append_event("Canalizar espírito causou %d de dano e reduziu a corrupção inimiga." % damage)

func _player_guard() -> void:
    player["guard"] = true
    player["spirit"] = mini(int(player["max_spirit"]), int(player["spirit"]) + 10)
    _append_event("Kataklysma entrou em guarda e recuperou 10 de espírito.")

func _player_purify() -> void:
    if int(player["spirit"]) < SPIRIT_PURIFY_COST:
        _append_event("Espírito insuficiente: são necessários %d." % SPIRIT_PURIFY_COST)
        _action_consumed = false
        return
    player["spirit"] = int(player["spirit"]) - SPIRIT_PURIFY_COST
    var heal: int = 14 + rng.randi_range(0, 6)
    player["hp"] = mini(int(player["max_hp"]), int(player["hp"]) + heal)
    var damage: int = _deal_damage(enemy, int(player["spell_power"]) + 4, "spirit_defense")
    player["corruption"] = maxi(0, int(player["corruption"]) - 2)
    _append_event("Purificar restaurou %d HP, removeu corrupção e causou %d de dano." % [heal, damage])

func _player_flee() -> void:
    var flee_roll: float = rng.randf()
    if flee_roll <= 0.7:
        _finish("fled", "Você recuou do encontro.")
    else:
        _append_event("A fuga falhou — a criatura bloqueou o caminho.")

func _enemy_turn() -> void:
    enemy["guard"] = false
    var corruption_roll: float = rng.randf()
    if corruption_roll < 0.28 and int(player["corruption"]) < 3:
        var raw_damage: int = int(enemy["spell_power"]) + rng.randi_range(-2, 4)
        var damage: int = _deal_damage(player, raw_damage, "spirit_defense")
        player["corruption"] = mini(3, int(player["corruption"]) + 1)
        _append_event("A Makrura lançou Névoa Corruptora: %d de dano e +1 corrupção." % damage)
    else:
        var raw_damage: int = int(enemy["power"]) + rng.randi_range(-3, 5)
        var damage: int = _deal_damage(player, raw_damage, "defense")
        _append_event("A Makrura atacou com as garras e causou %d de dano." % damage)
    player["guard"] = false

func _apply_player_start_turn() -> void:
    var stacks: int = int(player["corruption"])
    if stacks > 0:
        var dot_damage: int = stacks * 3
        player["hp"] = maxi(0, int(player["hp"]) - dot_damage)
        _append_event("A corrupção drenou %d HP." % dot_damage)

func _deal_damage(target: Dictionary, raw_damage: int, defense_key: String) -> int:
    var mitigation: int = int(target.get(defense_key, 0))
    if bool(target.get("guard", false)):
        mitigation += 12
    var damage: int = maxi(1, raw_damage - mitigation)
    target["hp"] = maxi(0, int(target["hp"]) - damage)
    return damage

func _finish(result: String, message: String) -> void:
    battle_result = result
    phase = result
    _append_event(message)

func _append_event(message: String) -> void:
    _events.append(message)
