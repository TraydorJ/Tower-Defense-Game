extends Node3D

const BOARD_SIZE := Vector2(24.0, 16.0)
const STARTING_GOLD := 260
const STARTING_LIVES := 20
const TOWER_DATA := {
	"Archer": {"cost": 80, "range": 4.6, "damage": 12.0, "rate": 0.72, "color": Color("#7ed957")},
	"Cannon": {"cost": 125, "range": 3.7, "damage": 34.0, "rate": 1.45, "color": Color("#ff9f43")},
	"Frost": {"cost": 145, "range": 4.1, "damage": 7.0, "rate": 0.95, "color": Color("#61d8ff")}
}
const PATH_POINTS: Array[Vector3] = [
	Vector3(-11.0, 0.0, -5.4),
	Vector3(-6.7, 0.0, -5.4),
	Vector3(-6.7, 0.0, 2.9),
	Vector3(-1.8, 0.0, 2.9),
	Vector3(-1.8, 0.0, -2.8),
	Vector3(3.4, 0.0, -2.8),
	Vector3(3.4, 0.0, 5.2),
	Vector3(8.0, 0.0, 5.2),
	Vector3(8.0, 0.0, 0.2),
	Vector3(11.0, 0.0, 0.2)
]
const PAD_POSITIONS: Array[Vector3] = [
	Vector3(-9.0, 0.0, -2.9), Vector3(-9.0, 0.0, 0.0),
	Vector3(-4.6, 0.0, -2.9), Vector3(-4.6, 0.0, 5.0),
	Vector3(-3.8, 0.0, 0.4), Vector3(0.5, 0.0, 0.0),
	Vector3(1.2, 0.0, -5.0), Vector3(5.5, 0.0, -5.0),
	Vector3(5.4, 0.0, 2.5), Vector3(9.8, 0.0, 3.0),
	Vector3(9.8, 0.0, -2.7), Vector3(0.8, 0.0, 6.7)
]

var gold := STARTING_GOLD
var lives := STARTING_LIVES
var wave := 0
var selected_type := "Archer"
var selected_tower: Dictionary = {}
var towers: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var projectiles: Array[Dictionary] = []
var pads: Array[Dictionary] = []
var path_lengths: Array[float] = []
var total_path_length := 0.0
var wave_active := false
var spawn_remaining := 0
var spawn_timer := 0.0
var game_over := false
var hud_label: Label
var message_label: Label
var wave_button: Button
var upgrade_button: Button
var sell_button: Button
var tower_buttons: Dictionary = {}

func _ready() -> void:
	_build_world()
	_build_path()
	_build_pads()
	_build_camera()
	_build_ui()
	_update_hud()
	_show_message("Choose a tower, then tap an empty build pad.")

func _process(delta: float) -> void:
	if game_over:
		return
	_update_wave_spawning(delta)
	_update_enemies(delta)
	_update_towers(delta)
	_update_projectiles(delta)
	_update_hud()

func _build_world() -> void:
	var ground := MeshInstance3D.new()
	var ground_mesh := BoxMesh.new()
	ground_mesh.size = Vector3(24.0, 0.45, 16.0)
	ground.mesh = ground_mesh
	ground.position = Vector3(0.0, -0.28, 0.0)
	ground.material_override = _material(Color("#477c53"))
	add_child(ground)

	var underlay := MeshInstance3D.new()
	var underlay_mesh := BoxMesh.new()
	underlay_mesh.size = Vector3(25.0, 0.5, 17.0)
	underlay.mesh = underlay_mesh
	underlay.position = Vector3(0.0, -0.58, 0.0)
	underlay.material_override = _material(Color("#293f3d"))
	add_child(underlay)

	for x in range(-11, 12, 2):
		for z in range(-7, 8, 2):
			var tuft := MeshInstance3D.new()
			var tuft_mesh := SphereMesh.new()
			tuft_mesh.radius = 0.07
			tuft_mesh.height = 0.12
			tuft.mesh = tuft_mesh
			tuft.position = Vector3(float(x) + randf_range(-0.35, 0.35), 0.02, float(z) + randf_range(-0.35, 0.35))
			tuft.material_override = _material(Color("#75a85d"))
			add_child(tuft)

func _build_path() -> void:
	path_lengths.clear()
	total_path_length = 0.0
	for i in range(PATH_POINTS.size() - 1):
		var a: Vector3 = PATH_POINTS[i]
		var b: Vector3 = PATH_POINTS[i + 1]
		var direction := b - a
		var length := direction.length()
		path_lengths.append(length)
		total_path_length += length

		var segment := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(1.65, 0.16, length + 0.06)
		segment.mesh = mesh
		segment.position = (a + b) * 0.5 + Vector3.UP * 0.12
		segment.rotation.y = atan2(direction.x, direction.z)
		segment.material_override = _material(Color("#c6a878"))
		add_child(segment)

		var edge := MeshInstance3D.new()
		var edge_mesh := BoxMesh.new()
		edge_mesh.size = Vector3(1.78, 0.07, length + 0.1)
		edge.mesh = edge_mesh
		edge.position = (a + b) * 0.5 + Vector3.UP * 0.06
		edge.rotation.y = segment.rotation.y
		edge.material_override = _material(Color("#8c704e"))
		add_child(edge)

func _build_pads() -> void:
	for i in range(PAD_POSITIONS.size()):
		var pad_node := Node3D.new()
		pad_node.position = PAD_POSITIONS[i]
		add_child(pad_node)

		var base := MeshInstance3D.new()
		var base_mesh := CylinderMesh.new()
		base_mesh.top_radius = 0.62
		base_mesh.bottom_radius = 0.72
		base_mesh.height = 0.22
		base.mesh = base_mesh
		base.position.y = 0.13
		base.material_override = _material(Color("#d8c99b"))
		pad_node.add_child(base)

		var ring := MeshInstance3D.new()
		var ring_mesh := TorusMesh.new()
		ring_mesh.inner_radius = 0.55
		ring_mesh.outer_radius = 0.62
		ring.mesh = ring_mesh
		ring.position.y = 0.26
		ring.material_override = _material(Color("#f1dc9a"))
		pad_node.add_child(ring)
		pads.append({"position": PAD_POSITIONS[i], "node": pad_node, "tower": null})

func _build_camera() -> void:
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 19.0
	camera.position = Vector3(0.0, 27.0, 0.0)
	camera.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	camera.current = true
	add_child(camera)

	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#b9d6c5")
	env.ambient_light_energy = 0.8
	environment.environment = env
	add_child(environment)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	layer.add_child(root)

	var top := PanelContainer.new()
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 14
	top.offset_top = 12
	top.offset_right = -14
	top.offset_bottom = 72
	top.add_theme_stylebox_override("panel", _panel_style(Color("#172c2b"), 0.92))
	root.add_child(top)

	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 22)
	top.add_child(top_row)
	hud_label = Label.new()
	hud_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud_label.add_theme_font_size_override("font_size", 20)
	hud_label.add_theme_color_override("font_color", Color("#f4f2dc"))
	top_row.add_child(hud_label)
	var pause_button := _make_button("Ⅱ", Color("#48615b"))
	pause_button.pressed.connect(_toggle_pause)
	top_row.add_child(pause_button)

	var bottom := PanelContainer.new()
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_left = 14
	bottom.offset_top = -118
	bottom.offset_right = -14
	bottom.offset_bottom = -12
	bottom.add_theme_stylebox_override("panel", _panel_style(Color("#172c2b"), 0.96))
	root.add_child(bottom)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	bottom.add_child(column)
	var tower_row := HBoxContainer.new()
	tower_row.add_theme_constant_override("separation", 8)
	column.add_child(tower_row)
	for tower_name in TOWER_DATA.keys():
		var data: Dictionary = TOWER_DATA[tower_name]
		var button := _make_button("%s  %d" % [tower_name, data["cost"]], data["color"])
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_select_tower_type.bind(tower_name))
		tower_row.add_child(button)
		tower_buttons[tower_name] = button

	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 8)
	column.add_child(action_row)
	message_label = Label.new()
	message_label.text = "Build your defense"
	message_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message_label.add_theme_color_override("font_color", Color("#e9e7d2"))
	action_row.add_child(message_label)
	upgrade_button = _make_button("UPGRADE", Color("#4d8d75"))
	upgrade_button.pressed.connect(_upgrade_selected)
	action_row.add_child(upgrade_button)
	sell_button = _make_button("SELL", Color("#8c6554"))
	sell_button.pressed.connect(_sell_selected)
	action_row.add_child(sell_button)
	wave_button = _make_button("START WAVE  ▶", Color("#e2a94b"))
	wave_button.pressed.connect(_start_wave)
	action_row.add_child(wave_button)

func _make_button(caption: String, color: Color) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(0, 42)
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_color_override("font_color", Color("#172522"))
	button.add_theme_stylebox_override("normal", _panel_style(color, 1.0))
	button.add_theme_stylebox_override("hover", _panel_style(color.lightened(0.12), 1.0))
	button.add_theme_stylebox_override("pressed", _panel_style(color.darkened(0.15), 1.0))
	return button

func _panel_style(color: Color, alpha: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(color.r, color.g, color.b, alpha)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	return material

func _select_tower_type(tower_name: String) -> void:
	selected_type = tower_name
	selected_tower = {}
	_show_message("Selected %s — tap an empty stone pad." % tower_name)
	_update_hud()

func _unhandled_input(event: InputEvent) -> void:
	if game_over:
		return
	var pressed := false
	var screen_position := Vector2.ZERO
	if event is InputEventScreenTouch and event.pressed:
		pressed = true
		screen_position = event.position
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pressed = true
		screen_position = event.position
	if not pressed:
		return
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	var origin := camera.project_ray_origin(screen_position)
	var direction := camera.project_ray_normal(screen_position)
	if absf(direction.y) < 0.0001:
		return
	var distance := -origin.y / direction.y
	if distance < 0.0:
		return
	var world_position := origin + direction * distance
	_handle_board_tap(world_position)

func _handle_board_tap(position: Vector3) -> void:
	var nearest_pad := -1
	var nearest_distance := 999.0
	for i in range(pads.size()):
		var pad_position: Vector3 = pads[i]["position"]
		var distance := Vector2(position.x - pad_position.x, position.z - pad_position.z).length()
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_pad = i
	if nearest_pad < 0 or nearest_distance > 0.82:
		return
	var pad: Dictionary = pads[nearest_pad]
	if pad["tower"] == null:
		_place_tower(nearest_pad)
	else:
		selected_tower = pad["tower"]
		_show_message("%s tower — level %d" % [selected_tower["type"], selected_tower["level"]])
		_update_hud()

func _place_tower(pad_index: int) -> void:
	var data: Dictionary = TOWER_DATA[selected_type]
	var cost: int = int(data["cost"])
	if gold < cost:
		_show_message("Not enough gold for %s." % selected_type)
		return
	gold -= cost
	var pad: Dictionary = pads[pad_index]
	var tower_node := Node3D.new()
	tower_node.position = pad["position"] + Vector3.UP * 0.22
	add_child(tower_node)

	var base := MeshInstance3D.new()
	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 0.4
	base_mesh.bottom_radius = 0.48
	base_mesh.height = 0.34
	base.mesh = base_mesh
	base.material_override = _material(Color("#6d776e"))
	tower_node.add_child(base)

	var shaft := MeshInstance3D.new()
	var shaft_mesh := CylinderMesh.new()
	shaft_mesh.top_radius = 0.22
	shaft_mesh.bottom_radius = 0.3
	shaft_mesh.height = 0.88
	shaft.mesh = shaft_mesh
	shaft.position.y = 0.57
	shaft.material_override = _material(data["color"].darkened(0.2))
	tower_node.add_child(shaft)

	var crown := MeshInstance3D.new()
	var crown_mesh := SphereMesh.new()
	crown_mesh.radius = 0.34
	crown_mesh.height = 0.58
	crown.mesh = crown_mesh
	crown.position.y = 1.12
	crown.material_override = _material(data["color"])
	tower_node.add_child(crown)

	var tower := {
		"type": selected_type,
		"level": 1,
		"node": tower_node,
		"pad_index": pad_index,
		"range": float(data["range"]),
		"damage": float(data["damage"]),
		"rate": float(data["rate"]),
		"cooldown": randf() * 0.25,
		"color": data["color"]
	}
	towers.append(tower)
	pads[pad_index]["tower"] = tower
	selected_tower = tower
	_show_message("%s tower built!" % selected_type)
	_update_hud()

func _upgrade_selected() -> void:
	if selected_tower.is_empty():
		return
	var cost := 65 * int(selected_tower["level"])
	if gold < cost:
		_show_message("Need %d gold to upgrade." % cost)
		return
	gold -= cost
	selected_tower["level"] = int(selected_tower["level"]) + 1
	selected_tower["damage"] = float(selected_tower["damage"]) * 1.55
	selected_tower["range"] = float(selected_tower["range"]) + 0.45
	_show_message("Tower upgraded to level %d!" % selected_tower["level"])
	_update_hud()

func _sell_selected() -> void:
	if selected_tower.is_empty():
		return
	var tower: Dictionary = selected_tower
	gold += int(TOWER_DATA[tower["type"]]["cost"] * 0.65)
	var pad_index: int = tower["pad_index"]
	if is_instance_valid(tower["node"]):
		tower["node"].queue_free()
	pads[pad_index]["tower"] = null
	towers.erase(tower)
	selected_tower = {}
	_show_message("Tower sold.")
	_update_hud()

func _start_wave() -> void:
	if wave_active or game_over:
		return
	wave += 1
	wave_active = true
	spawn_remaining = 7 + wave * 2
	spawn_timer = 0.15
	wave_button.disabled = true
	_show_message("Wave %d incoming!" % wave)
	_update_hud()

func _update_wave_spawning(delta: float) -> void:
	if not wave_active:
		return
	if spawn_remaining > 0:
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			_spawn_enemy()
			spawn_remaining -= 1
			spawn_timer = maxf(0.38, 0.92 - float(wave) * 0.018)
	elif enemies.is_empty():
		wave_active = false
		gold += 45 + wave * 8
		wave_button.disabled = false
		_show_message("Wave cleared! Supply bonus +%d gold." % (45 + wave * 8))
		_update_hud()

func _spawn_enemy() -> void:
	var enemy := Node3D.new()
	add_child(enemy)
	var body := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.34 if wave < 4 else 0.4
	mesh.height = mesh.radius * 2.0
	body.mesh = mesh
	body.material_override = _material(Color("#d85c54") if wave % 4 != 0 else Color("#8d72d9"))
	enemy.add_child(body)
	var eye := MeshInstance3D.new()
	var eye_mesh := SphereMesh.new()
	eye_mesh.radius = 0.09
	eye_mesh.height = 0.18
	eye.mesh = eye_mesh
	eye.position = Vector3(0.13, 0.12, -0.22)
	eye.material_override = _material(Color("#fff2c8"))
	enemy.add_child(eye)
	enemy.position = PATH_POINTS[0] + Vector3.UP * 0.48
	var health := 42.0 + float(wave) * 12.0
	enemies.append({"node": enemy, "distance": 0.0, "health": health, "max_health": health, "speed": 1.8 + float(wave) * 0.045, "slow": 0.0})

func _position_on_path(distance: float) -> Vector3:
	var remaining := distance
	for i in range(path_lengths.size()):
		var segment_length: float = path_lengths[i]
		if remaining <= segment_length:
			var t := clampf(remaining / segment_length, 0.0, 1.0)
			return PATH_POINTS[i].lerp(PATH_POINTS[i + 1], t)
		remaining -= segment_length
	return PATH_POINTS[PATH_POINTS.size() - 1]

func _update_enemies(delta: float) -> void:
	for i in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[i]
		if enemy["slow"] > 0.0:
			enemy["slow"] = maxf(0.0, float(enemy["slow"]) - delta)
		else:
			enemy["distance"] = float(enemy["distance"]) + float(enemy["speed"]) * delta
		if float(enemy["distance"]) >= total_path_length:
			_remove_enemy(i, false)
			lives -= 1
			if lives <= 0:
				_end_game()
			continue
		enemy["node"].position = _position_on_path(float(enemy["distance"])) + Vector3.UP * 0.48

func _update_towers(delta: float) -> void:
	for tower in towers:
		tower["cooldown"] = float(tower["cooldown"]) - delta
		if float(tower["cooldown"]) > 0.0:
			continue
		var tower_position: Vector3 = tower["node"].global_position
		var target_index := -1
		var best_progress := -1.0
		for i in range(enemies.size()):
			var enemy: Dictionary = enemies[i]
			var enemy_position: Vector3 = enemy["node"].global_position
			var distance := Vector2(tower_position.x - enemy_position.x, tower_position.z - enemy_position.z).length()
			if distance <= float(tower["range"]) and float(enemy["distance"]) > best_progress:
				best_progress = float(enemy["distance"])
				target_index = i
		if target_index >= 0:
			var target: Dictionary = enemies[target_index]
			_fire_projectile(tower, target)
			tower["cooldown"] = float(tower["rate"])

func _fire_projectile(tower: Dictionary, target: Dictionary) -> void:
	var shot := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.13
	mesh.height = 0.26
	shot.mesh = mesh
	shot.material_override = _material(tower["color"])
	shot.position = tower["node"].global_position + Vector3.UP * 1.25
	add_child(shot)
	projectiles.append({"node": shot, "target": target, "damage": tower["damage"], "speed": 10.5, "slow": tower["type"] == "Frost"})

func _update_projectiles(delta: float) -> void:
	for i in range(projectiles.size() - 1, -1, -1):
		var shot: Dictionary = projectiles[i]
		var node: Node3D = shot["node"]
		var target: Dictionary = shot["target"]
		if not is_instance_valid(node) or not is_instance_valid(target["node"]):
			if is_instance_valid(node):
				node.queue_free()
			projectiles.remove_at(i)
			continue
		var destination: Vector3 = target["node"].global_position + Vector3.UP * 0.25
		var offset := destination - node.global_position
		var step := float(shot["speed"]) * delta
		if offset.length() <= step + 0.12:
			target["health"] = float(target["health"]) - float(shot["damage"])
			if shot["slow"]:
				target["slow"] = 1.1
			if float(target["health"]) <= 0.0:
				var enemy_index := enemies.find(target)
				if enemy_index >= 0:
					_remove_enemy(enemy_index, true)
			node.queue_free()
			projectiles.remove_at(i)
		else:
			node.global_position += offset.normalized() * step

func _remove_enemy(index: int, reward: bool) -> void:
	var enemy: Dictionary = enemies[index]
	if reward:
		gold += 12 + wave
	if is_instance_valid(enemy["node"]):
		enemy["node"].queue_free()
	enemies.remove_at(index)

func _toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	if get_tree().paused:
		_show_message("Paused — tap Ⅱ to resume.")
	else:
		_show_message("Defend the greenlands!")

func _end_game() -> void:
	game_over = true
	wave_active = false
	wave_button.disabled = true
	_show_message("The bastion has fallen. Refresh to try again.")
	_update_hud()

func _show_message(text: String) -> void:
	if is_instance_valid(message_label):
		message_label.text = text

func _update_hud() -> void:
	if not is_instance_valid(hud_label):
		return
	hud_label.text = "✦ %d     ♥ %d     WAVE %d     ENEMIES %d" % [gold, lives, wave, enemies.size()]
	if is_instance_valid(upgrade_button):
		upgrade_button.disabled = selected_tower.is_empty()
	if is_instance_valid(sell_button):
		sell_button.disabled = selected_tower.is_empty()
	if is_instance_valid(wave_button):
		wave_button.disabled = wave_active or game_over
	for tower_name in tower_buttons:
		var data: Dictionary = TOWER_DATA[tower_name]
		tower_buttons[tower_name].disabled = gold < int(data["cost"]) or game_over
