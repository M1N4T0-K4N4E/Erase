extends CharacterBody2D

# Preload the slash attack scene
const SlashAttack = preload("res://slash_attack.tscn")

var attack_cooldown = 0.5
var can_attack = true

# Player health system
var max_health = 10
var current_health = 10
var damage_cooldown = 1.0  # Invincibility frames after taking damage
var can_take_damage = true

func _ready():
	print("Player health: ", current_health, "/", max_health)

func _physics_process(delta: float):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * 600
	move_and_slide()
	
	if velocity.length() > 0.0:
		get_node("player").play_walk_animation()
	else :
		get_node("player").play_idle_animation()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and can_attack:
			perform_slash_attack()

func perform_slash_attack():
	if not can_attack:
		return
		
	# Get mouse position relative to player
	var mouse_pos = get_global_mouse_position()
	var attack_direction = (mouse_pos - global_position).normalized()
	
	# Create slash attack
	var slash = SlashAttack.instantiate()
	get_parent().add_child(slash)
	
	# Position slash slightly in front of player
	var attack_distance = 100  # Adjust this value as needed
	slash.global_position = global_position + attack_direction * attack_distance
	
	# Set the direction for the slash
	slash.set_direction(attack_direction)
	
	# Play slash animation on player
	get_node("player").play_slash_animation()
	
	# Start cooldown
	can_attack = false
	get_tree().create_timer(attack_cooldown).timeout.connect(_on_attack_cooldown_finished)

func _on_attack_cooldown_finished():
	can_attack = true

func take_damage(amount: int = 1):
	if not can_take_damage:
		return
		
	current_health -= amount
	print("Player took ", amount, " damage! Health: ", current_health, "/", max_health)
	
	# Update UI if game scene has the update function
	var game_scene = get_tree().current_scene
	if game_scene and game_scene.has_method("update_health_display"):
		game_scene.update_health_display()
	
	if current_health <= 0:
		die()
	else:
		# Start damage cooldown (invincibility frames)
		can_take_damage = false
		get_tree().create_timer(damage_cooldown).timeout.connect(_on_damage_cooldown_finished)
		
		# Visual feedback - flash the player
		flash_player()

func _on_damage_cooldown_finished():
	can_take_damage = true
	print("Player can take damage again")

func flash_player():
	# Flash effect to show damage taken
	var player_sprite = get_node("player")
	if player_sprite:
		var tween = create_tween()
		tween.set_loops(3)
		tween.tween_property(player_sprite, "modulate:a", 0.5, 0.1)
		tween.tween_property(player_sprite, "modulate:a", 1.0, 0.1)

func die():
	print("Player died!")
	# Get the current wave from the game scene for high score
	var game_scene = get_tree().current_scene
	var final_wave = 1
	if game_scene and game_scene.has_method("get_current_wave"):
		final_wave = game_scene.get_current_wave()
	
	# Show game over screen with high score
	show_game_over_screen(final_wave)

func show_game_over_screen(final_wave: int):
	# Pause the game
	get_tree().paused = true
	
	# Create game over UI overlay
	var game_over_screen = Control.new()
	game_over_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game_over_screen.process_mode = Node.PROCESS_MODE_WHEN_PAUSED  # Allow UI to work when paused
	
	# Blurred background effect
	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.6)  # Darker semi-transparent overlay
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	game_over_screen.add_child(background)
	
	# Add blur effect by creating multiple overlapping semi-transparent layers
	for i in range(3):
		var blur_layer = ColorRect.new()
		blur_layer.color = Color(0.1, 0.1, 0.1, 0.2)  # Multiple dark layers for blur effect
		blur_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		game_over_screen.add_child(blur_layer)
	
	# Main container for centering content
	var container = VBoxContainer.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	container.custom_minimum_size = Vector2(400, 300)
	
	# Game Over title
	var title_label = Label.new()
	title_label.text = "GAME OVER"
	title_label.add_theme_font_size_override("font_size", 64)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	title_label.add_theme_color_override("font_color", Color.RED)
	container.add_child(title_label)
	
	# Add spacing
	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(0, 40)
	container.add_child(spacer1)
	
	# High score label
	var score_label = Label.new()
	score_label.text = "Waves Survived: " + str(final_wave - 1)
	score_label.add_theme_font_size_override("font_size", 36)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	score_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	score_label.add_theme_color_override("font_color", Color.YELLOW)
	container.add_child(score_label)
	
	# Add spacing
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 40)
	container.add_child(spacer2)
	
	# Return to title button
	var return_button = Button.new()
	return_button.text = "Return to Title Screen"
	return_button.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	return_button.custom_minimum_size = Vector2(300, 60)
	return_button.add_theme_font_size_override("font_size", 24)
	
	# Center the button
	var button_container = HBoxContainer.new()
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	button_container.add_child(return_button)
	container.add_child(button_container)
	
	game_over_screen.add_child(container)
	
	# Add to scene
	get_tree().current_scene.add_child(game_over_screen)
	
	# Connect button signal
	return_button.pressed.connect(_on_return_to_title_pressed)

func _on_return_to_title_pressed():
	# Unpause the game before changing scenes
	get_tree().paused = false
	get_tree().change_scene_to_file("res://TitleScreen.tscn")
