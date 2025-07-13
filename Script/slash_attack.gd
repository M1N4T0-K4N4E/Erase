extends Area2D

@onready var animation_player = $AnimationPlayer
@onready var collision = $CollisionShape2D

var damage = 1
var attack_duration = 0.3
var slash_size = 2.5  # Scale factor for the slash size

func _ready():
	# Connect to detect when mobs enter the attack area
	body_entered.connect(_on_body_entered)
	
	# Make slash effect appear on top of everything
	z_index = 100
	z_as_relative = false
	
	# Scale the entire slash attack
	scale = Vector2(slash_size, slash_size)
	
	# Play the frame animation (sprite animation)
	if animation_player:
		animation_player.play("default")  # This plays the sprite frame animation
		animation_player.animation_finished.connect(_on_animation_finished)
	
	# Auto-destroy after duration
	get_tree().create_timer(attack_duration).timeout.connect(queue_free)

func set_direction(direction: Vector2):
	# Rotate the slash to face the target direction
	rotation = direction.angle()

func _on_body_entered(body):
	# Check if the body is a mob or monster (exclude player)
	if body.is_in_group("mobs") or body.is_in_group("monsters"):
		# Deal damage to the enemy
		if body.has_method("take_damage"):
			body.take_damage(damage)
		else:
			body.queue_free()

func _on_animation_finished():
	queue_free()
