extends CharacterBody2D

var player
var health = 100

func _ready() -> void:
	player = get_node("../player")

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 300.0
	move_and_slide()
	
	if velocity.length() > 0.0:
		get_node("chroma").play_walk()
	else :
		get_node("chroma").play_idle()

func take_damage(amount: int = 1):
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
