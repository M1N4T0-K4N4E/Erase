extends CharacterBody2D

func _physics_process(delta: float):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * 600
	move_and_slide()
	
	if velocity.length() > 0.0:
		get_node("player").play_walk_animation()
	else :
		get_node("player").play_idle_animation()
