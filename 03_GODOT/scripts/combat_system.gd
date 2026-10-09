class_name KataklysmaCombatSystem
extends RefCounted

## Deterministic, data-driven turn combat for the first playable slice.
## The UI is kept outside this class so the rules can later be reused by
## quests, bosses and a dedicated battle scene.

const ACTIONS := ["strike", "channel", "guard", "purify", "flee", "terrain", "neutralize"]
const SPIRIT_CHANNEL_COST := 18
const SPIRIT_PURIFY_COST := 25

var rng := RandomNumberGenerator.new()
var player: Dictionary = {}
var enemy: Dictionary = {}
var phase := "idle"
var round := 0
var battle_result := ""
var initiative_order := "player_first"
var _events: Array[String] = []
var _action_consumed := false
var _is_campaign_boss := false
var _boss_phase := 0
var _boss_context: Dictionary = {}

func _init() -> void:
    rng.seed = 1337

func start_battle(enemy_id: String = "corrupted_makrura", campaign_boss := false, boss_context: Dictionary = {}) -> Dictionary:
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
    if campaign_boss:
        var actor_attributes: Dictionary = boss_context.get("attributes", {})
        player["max_hp"] = 150 + int(float(actor_attributes.get("stamina", 54)) * 0.35)
        player["hp"] = player["max_hp"]
        player["max_spirit"] = 100
        player["spirit"] = mini(100, 60 + int(float(actor_attributes.get("spirit", 50)) * 0.3))
        player["power"] = 20 + int(float(actor_attributes.get("agility", 50)) * 0.08)
        player["spell_power"] = 25 + int(float(actor_attributes.get("intellect", 50)) * 0.12)
        player["defense"] = 9 + int(float(actor_attributes.get("stamina", 50)) * 0.07)
        player["spirit_defense"] = 9 + int(float(actor_attributes.get("spirit", 50)) * 0.05)
        player["agility"] = 12 + int(float(actor_attributes.get("agility", 50)) * 0.04)
    _is_campaign_boss = campaign_boss and enemy_id in ["corrupted_makrura", "makrura_corrupted"]
    _boss_phase = 1 if _is_campaign_boss else 0
    _boss_context = boss_context.duplicate(true) if _is_campaign_boss else {}
    enemy = _build_enemy(enemy_id, _is_campaign_boss, _boss_context)
    var player_initiative: int = int(player["agility"])
    var enemy_initiative: int = int(enemy["agility"])
    initiative_order = "player_first" if player_initiative >= enemy_initiative else "enemy_first"
    phase = "player_turn" if initiative_order == "player_first" else "enemy_turn"
    round = 1
    battle_result = ""
    _events.clear()
    _append_event("Iniciativa: %s." % ("Kataklysma" if initiative_order == "player_first" else enemy["display_name"]))
    if phase == "enemy_turn":
        _enemy_turn()
        if int(player.get("hp", 0)) <= 0:
            _finish("defeat", "Kataklysma caiu antes de agir.")
        else:
            phase = "player_turn"
            _append_event("Round 1 — sua vez.")
    else:
        _append_event("Round 1 — sua vez.")
    return get_snapshot()

func _build_enemy(enemy_id: String, campaign_boss := false, boss_context: Dictionary = {}) -> Dictionary:
    if enemy_id == "wild_boar":
        return {
            "id": enemy_id,
            "display_name": "Javali Selvagem",
            "max_hp": 76,
            "hp": 76,
            "power": 19,
            "spell_power": 11,
            "defense": 7,
            "spirit_defense": 5,
            "agility": 17,
            "guard": false,
            "corruption": 0,
        }
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
    var makrura := {
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
    if campaign_boss:
        if bool(boss_context.get("spirit_helped", false)):
            makrura["max_hp"] = 84
            makrura["hp"] = 84
            makrura["power"] = 18
        makrura["is_campaign_boss"] = true
        makrura["boss_phase"] = 1
        makrura["conductive_grounded"] = false
        makrura["eggs_cleared"] = false
        makrura["ritual_stone_active"] = true
        makrura["analysis_done"] = bool(boss_context.get("analysis_done", false))
    return makrura

func get_snapshot() -> Dictionary:
    return {
        "phase": phase,
        "round": round,
        "initiative": initiative_order,
        "result": battle_result,
        "player": player.duplicate(true),
        "enemy": enemy.duplicate(true),
        "events": _events.duplicate(),
        "actions": _available_actions(),
        "boss_phase": _boss_phase,
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
        "terrain":
            _player_use_arena()
        "neutralize":
            _player_neutralize_boss()

    if not _action_consumed:
        return get_snapshot()
    if phase != "player_turn":
        return get_snapshot()
    if int(enemy.get("hp", 0)) <= 0:
        if _is_campaign_boss and _boss_phase < 3:
            _advance_makrura_phase()
        else:
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

func _player_use_arena() -> void:
    if not _is_campaign_boss:
        _append_event("Não há mecânica de arena ativa neste encontro.")
        _action_consumed = false
        return
    match _boss_phase:
        1:
            if bool(enemy.get("conductive_grounded", false)) or bool(enemy.get("analysis_done", false)):
                _append_event("A energia das poças já foi estabilizada.")
                _action_consumed = false
                return
            enemy["conductive_grounded"] = true
            player["guard"] = true
            _append_event("Kataklysma aterra a corrente nas poças condutivas; a próxima descarga é evitada.")
        2:
            if bool(enemy.get("eggs_cleared", false)):
                _append_event("Os ovos já foram neutralizados.")
                _action_consumed = false
                return
            enemy["eggs_cleared"] = true
            enemy["defense"] = maxi(0, int(enemy.get("defense", 0)) - 4)
            enemy["spirit_defense"] = maxi(0, int(enemy.get("spirit_defense", 0)) - 3)
            _append_event("Os ovos foram afastados do foco corrupto; o Makrura perde defesa e deixa de se regenerar.")
        3:
            if not bool(enemy.get("ritual_stone_active", true)):
                _append_event("A pedra ritual já está desativada.")
                _action_consumed = false
                return
            enemy["ritual_stone_active"] = false
            enemy["spell_power"] = maxi(0, int(enemy.get("spell_power", 0)) - 7)
            player["corruption"] = 0
            _append_event("A pedra ritual foi interrompida; a corrupção deixa de alimentar os ataques do Makrura.")

func _advance_makrura_phase() -> void:
    _boss_phase += 1
    var recovered_hp := mini(int(player.get("max_hp", 1)) - int(player.get("hp", 0)), maxi(1, roundi(float(player.get("max_hp", 1)) * 0.3)))
    var recovered_spirit := mini(int(player.get("max_spirit", 1)) - int(player.get("spirit", 0)), 18)
    player["hp"] = int(player.get("hp", 0)) + recovered_hp
    player["spirit"] = int(player.get("spirit", 0)) + recovered_spirit
    player["corruption"] = maxi(0, int(player.get("corruption", 0)) - 1)
    enemy = _build_enemy("corrupted_makrura", true, _boss_context)
    enemy["boss_phase"] = _boss_phase
    _append_event("A ruptura entre as fases oferece um breve respiro: +%d HP, +%d Espírito e −1 Corrupção." % [recovered_hp, recovered_spirit])
    if _boss_phase == 2:
        enemy["display_name"] = "Makrura Corrompida • Fase 2"
        enemy["max_hp"] = 80 if bool(_boss_context.get("spirit_helped", false)) else 100
        enemy["hp"] = int(enemy["max_hp"])
        enemy["power"] = 22
        enemy["defense"] = 11
        enemy["spirit_defense"] = 10
        enemy["eggs_cleared"] = false
        _append_event("Fase 2/3 — ovos começam a alimentar a criatura. Use [6] para neutralizá-los.")
    else:
        enemy["display_name"] = "Makrura Corrompida • Fase 3"
        enemy["max_hp"] = 90 if bool(_boss_context.get("spirit_helped", false)) else 110
        enemy["hp"] = int(enemy["max_hp"])
        enemy["power"] = 24
        enemy["spell_power"] = 24
        enemy["defense"] = 12
        enemy["spirit_defense"] = 11
        enemy["ritual_stone_active"] = true
        _append_event("Fase 3/3 — a pedra ritual concentra a corrupção. Use [6] para interrompê-la.")

func _available_actions() -> Array[String]:
    var result: Array[String] = ["strike", "channel", "guard", "purify", "flee"]
    if _is_campaign_boss:
        result.append("terrain")
        if bool(_boss_context.get("spirit_helped", false)) or bool(_boss_context.get("analysis_done", false)):
            result.append("neutralize")
    return result

func _player_neutralize_boss() -> void:
    if not _is_campaign_boss or not (bool(_boss_context.get("spirit_helped", false)) or bool(_boss_context.get("analysis_done", false))):
        _append_event("Sem a ajuda do espírito ou a análise da contaminação, a neutralização ainda não é possível.")
        _action_consumed = false
        return
    if int(player.get("spirit", 0)) < 40:
        _append_event("São necessários 40 pontos de Espírito para tentar neutralizar o foco.")
        _action_consumed = false
        return
    player["spirit"] = int(player["spirit"]) - 40
    var attributes: Dictionary = _boss_context.get("attributes", {})
    var spirit_route_ready := bool(_boss_context.get("spirit_helped", false)) and int(attributes.get("spirit", 0)) >= 75
    var analysis_route_ready := bool(_boss_context.get("analysis_done", false)) and int(attributes.get("intellect", 0)) >= 85
    if (bool(_boss_context.get("spirit_helped", false)) and bool(_boss_context.get("analysis_done", false))) or spirit_route_ready or analysis_route_ready:
        _finish("neutralized", "A energia elemental e a leitura do padrão se combinam; o Makrura é neutralizado sem ser morto.")
        return
    var chance := clampf(0.45 + float(attributes.get("spirit", 0)) * 0.003 + float(attributes.get("intellect", 0)) * 0.002, 0.45, 0.9)
    if rng.randf() <= chance:
        _finish("neutralized", "O foco corrupto é interrompido e o Makrura é neutralizado.")
    else:
        _append_event("A tentativa enfraquece a corrupção, mas não a interrompe. O combate continua.")

func _enemy_turn() -> void:
    enemy["guard"] = false
    if _is_campaign_boss and _boss_phase == 2 and not bool(enemy.get("eggs_cleared", false)):
        enemy["hp"] = mini(int(enemy.get("max_hp", 1)), int(enemy.get("hp", 0)) + 8)
        _append_event("Os ovos restauram 8 HP ao Makrura.")
    var enemy_name := str(enemy.get("display_name", "A criatura"))
    var corruption_roll: float = rng.randf()
    if corruption_roll < 0.28 and int(player["corruption"]) < 3:
        var raw_damage: int = int(enemy["spell_power"]) + rng.randi_range(-2, 4)
        var damage: int = _deal_damage(player, raw_damage, "spirit_defense")
        player["corruption"] = mini(3, int(player["corruption"]) + 1)
        _append_event("%s lançou Névoa Corruptora: %d de dano e +1 corrupção." % [enemy_name, damage])
    else:
        var raw_damage: int = int(enemy["power"]) + rng.randi_range(-3, 5)
        var damage: int = _deal_damage(player, raw_damage, "defense")
        _append_event("%s atacou e causou %d de dano." % [enemy_name, damage])
    player["guard"] = false
    if _is_campaign_boss and _boss_phase == 1 and round % 2 == 0 and not bool(enemy.get("conductive_grounded", false)) and not bool(enemy.get("analysis_done", false)):
        player["hp"] = maxi(0, int(player.get("hp", 0)) - 8)
        _append_event("Descarga das poças condutivas causa 8 de dano.")
    if _is_campaign_boss and _boss_phase == 3 and bool(enemy.get("ritual_stone_active", false)):
        player["corruption"] = mini(3, int(player.get("corruption", 0)) + 1)
        _append_event("A pedra ritual acrescenta 1 corrupção.")

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
