extends CharacterBody2D

var player

func _ready() -> void:
	player = get_node("../player")

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 300.0
	move_and_slide()
	
