extends CharacterBody2D

func _physics_process(delta: float):
	var direction = Input.get_vector("left","right","up","down")
	velocity = direction * 600
	move_and_slide()
