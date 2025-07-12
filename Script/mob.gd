extends CharacterBody2D

var player
var health = 3
var damage_amount = 1
var attack_cooldown = 1.0  # How often mob can damage player
var can_damage_player = true

func _ready() -> void:
	player = get_node("../player")
	# Add mob to a group for easy identification
	add_to_group("mobs")

func _physics_process(delta):
	if not player:
		return
		
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 200.0
	move_and_slide()
	
	if velocity.length() > 0.0:
		get_node("Slime").play_walk()
	else :
		get_node("Slime").play_idle()
	
	# Check for collision with player
	check_player_collision()

func check_player_collision():
	if not player or not can_damage_player:
		return
		
	var distance_to_player = global_position.distance_to(player.global_position)
	var collision_distance = 90.0  # Adjust this based on your sprite sizes
	
	if distance_to_player <= collision_distance:
		# Damage the player
		if player.has_method("take_damage"):
			player.take_damage(damage_amount)
			
			# Start attack cooldown
			can_damage_player = false
			get_tree().create_timer(attack_cooldown).timeout.connect(_on_attack_cooldown_finished)

func _on_attack_cooldown_finished():
	can_damage_player = true

func take_damage(amount: int = 1):
	get_node("Slime").play_hurt()
	health -= amount
	if health <= 0:
		die()

func die():
	# Play death animation if you have one
	# If you have a death animation, uncomment the lines below:
	# if has_node("mob") and get_node("mob").has_method("play_death_animation"):
	#     get_node("mob").play_death_animation()
	#     await get_tree().create_timer(0.5).timeout  # Wait for animation
	
	queue_free()
	
