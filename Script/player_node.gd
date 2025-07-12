extends Node2D

@onready var sword = $Sword

var sword_size = 2.0  # Scale factor for sword size

func _ready():
	# Set initial sword size
	if sword:
		sword.scale = Vector2(sword_size, sword_size)

func play_idle_animation():
	%AnimationPlayer.play("idle")


func play_walk_animation():
	%AnimationPlayer.play("walk")


func play_slash_animation():
	# Play slash animation if it exists, otherwise fallback to idle
	if %AnimationPlayer.has_animation("slash"):
		%AnimationPlayer.play("slash")
	else:
		%AnimationPlayer.play("idle")
	
	# Play sword slash effect
	if sword and sword.has_node("slash_animation"):
		sword.get_node("slash_animation").play("default")


func get_slash_direction() -> Vector2:
	# Return the direction the slash should face
	var mouse_pos = get_global_mouse_position()
	return (mouse_pos - global_position).normalized()


func _process(_delta):
	# Sword stays in fixed position and orientation
	if sword:
		# Keep sword at consistent scale without flipping
		sword.scale = Vector2(sword_size, sword_size)
