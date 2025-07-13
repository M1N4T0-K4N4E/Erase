extends Node2D

# Preload the mob scenes
const SlimeMobScene = preload("res://characters/slime/mob_test.tscn")
const MonsterScene = preload("res://characters/customized/monster.tscn")

@onready var player = $player
@onready var health_label = $UI/HealthContainer/HealthLabel
@onready var current_wave_label = $UI/CurrentWaveLabel

# Mob spawning settings
var spawn_count = 5  # Number of mobs to spawn each wave
var spawn_area_min = Vector2(100, 100)  # Minimum spawn coordinates
var spawn_area_max = Vector2(1700, 980)  # Maximum spawn coordinates (screen boundaries)
var current_wave = 1
var is_spawning_wave = false  # Prevent continuous spawning
var monster_spawned_this_wave = false  # Track if monster was spawned this wave

# UI elements
var notice_screen: Control
var wave_label: Label


func _ready():
	# Connect to player health changes
	if player:
		# Update health display initially
		update_health_display()
	
	# Create notice screen UI
	create_notice_screen()
	
	# Start checking for dead mobs
	set_process(true)

func _on_button_pressed():
	get_tree().change_scene_to_file("res://TitleScreen.tscn")
	pass # Replace with function body.

func update_health_display():
	if player and health_label:
		health_label.text = "Health: %d/%d" % [player.current_health, player.max_health]
		
func update_wave_display():
	# Update current wave status
	current_wave_label.text = "Wave %d" % [current_wave]

func _process(_delta):
	# Update health display continuously
	update_health_display()
	
	# Check if all slimes are dead (monsters don't count for wave progression)
	var slimes_alive = 0
	for mob in get_tree().get_nodes_in_group("mobs"):
		# Only count slimes (check if they have a "Slime" node)
		if mob.has_node("Slime"):
			slimes_alive += 1
	
	# Spawn new wave when all slimes are dead (regardless of monsters)
	if slimes_alive == 0 and not is_spawning_wave:
		spawn_new_wave()

func create_notice_screen():
	# Create a UI overlay for wave notifications
	notice_screen = Control.new()
	notice_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	#notice_screen.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	notice_screen.visible = false
	
	# Background panel
	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.7)  # Semi-transparent black
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	notice_screen.add_child(background)
	
	# Wave label
	wave_label = Label.new()
	wave_label.text = "Wave 1 Cleared!"
	wave_label.add_theme_font_size_override("font_size", 48)
	wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wave_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	wave_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	notice_screen.add_child(wave_label)
	
	
	# Add to UI layer
	var ui_node = get_node("UI")
	if ui_node:
		ui_node.add_child(notice_screen)
	else:
		add_child(notice_screen)

func spawn_new_wave():
	if is_spawning_wave:  # Already spawning, don't spawn again
		return
		
	is_spawning_wave = true
	monster_spawned_this_wave = false  # Reset monster spawn flag for new wave
	print("All mobs defeated! Spawning wave ", current_wave)
	
	# Show wave notice
	show_wave_notice()
	
	# Wait a moment, then spawn mobs
	await get_tree().create_timer(3.0).timeout
	
	# Increase difficulty by spawning more mobs each wave
	var mobs_to_spawn = spawn_count + (current_wave - 1) * 2  # +2 mobs per wave
	
	# Spawn new mobs at random positions
	for i in range(mobs_to_spawn):
		spawn_mob_at_random_position()
	
	current_wave += 1
	print("Wave ", current_wave - 1, " spawned with ", mobs_to_spawn, " mobs")
	
	update_wave_display()
	
	# Reset the spawning flag
	is_spawning_wave = false

func spawn_mob_at_random_position():
	# Always spawn a slime mob
	var mob_instance = SlimeMobScene.instantiate()
	
	# 30% chance to spawn a monster instead, but only if none spawned this wave yet
	var monster_chance = 0.05
	if not monster_spawned_this_wave and randf() < monster_chance:
		mob_instance = MonsterScene.instantiate()
		monster_spawned_this_wave = true  # Mark that monster was spawned this wave
	
	# Generate random position within spawn area
	var random_x = randf_range(spawn_area_min.x, spawn_area_max.x)
	var random_y = randf_range(spawn_area_min.y, spawn_area_max.y)
	
	# Make sure spawn position is not too close to player
	var player_pos = player.global_position
	var spawn_pos = Vector2(random_x, random_y)
	var min_distance_from_player = 200.0
	
	# Keep trying new positions if too close to player
	var attempts = 0
	while spawn_pos.distance_to(player_pos) < min_distance_from_player and attempts < 10:
		random_x = randf_range(spawn_area_min.x, spawn_area_max.x)
		random_y = randf_range(spawn_area_min.y, spawn_area_max.y)
		spawn_pos = Vector2(random_x, random_y)
		attempts += 1
	
	mob_instance.global_position = spawn_pos
	add_child(mob_instance)

func show_wave_notice():
	if notice_screen and wave_label:
		wave_label.text = "Wave %d Incoming!" % [current_wave + 1]
		
		notice_screen.visible = true
		
		# Hide notice after 2 seconds
		await get_tree().create_timer(2.0).timeout
		notice_screen.visible = false

func get_current_wave():
	return current_wave
