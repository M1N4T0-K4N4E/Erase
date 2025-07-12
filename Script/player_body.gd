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
	# Add death logic here (restart level, game over screen, etc.)
	get_tree().change_scene_to_file("TitleScreen.tscn")
