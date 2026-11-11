extends SceneTree

const GAME_SCENE := preload("res://scenes/main.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game := GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame

	_check(game.gold == 260, "Starting gold should be 260")
	_check(game.lives == 20, "Starting lives should be 20")
	_check(game.pads.size() == 12, "Expected 12 build pads")
	_check(game.total_path_length > 30.0, "Enemy route should have a valid length")

	game._place_tower(0)
	_check(game.towers.size() == 1, "Tower placement should create one tower")
	_check(game.gold == 180, "Archer placement should deduct 80 gold")

	game._spawn_enemy()
	_check(game.enemies.size() == 1, "Enemy spawn should create one enemy")
	var health_before: float = game.enemies[0]["health"]
	game.towers[0]["cooldown"] = 0.0
	game._update_towers(0.01)
	_check(game.projectiles.size() == 1, "Tower should acquire a target and fire")
	game._update_projectiles(1.0)
	_check(float(game.enemies[0]["health"]) < health_before, "Projectile should damage its target")

	game._upgrade_selected()
	_check(int(game.selected_tower["level"]) == 2, "Upgrade should increase tower level")
	_check(game.gold == 115, "Upgrade should deduct 65 gold")

	game._sell_selected()
	_check(game.towers.is_empty(), "Selling should remove the tower")
	_check(game.gold == 167, "Selling should refund 65 percent of base cost")

	game._start_wave()
	_check(game.wave == 1 and game.wave_active, "Starting a wave should activate wave one")
	game._update_wave_spawning(0.2)
	_check(game.enemies.size() == 2, "Wave spawning should add an enemy to the existing test enemy")

	var remaining_lives: int = game.lives
	game.enemies[0]["distance"] = game.total_path_length + 1.0
	game._update_enemies(0.01)
	_check(game.lives == remaining_lives - 1, "An escaped enemy should cost one life")
	_check(game.enemies.size() == 1, "Escaped enemy should be removed")

	game.queue_free()
	print("GAMEPLAY_SMOKE_TEST: PASS")
	quit(0)

func _check(condition: bool, message: String) -> void:
	if not condition:
		push_error("GAMEPLAY_SMOKE_TEST: " + message)
		quit(1)
