extends CharacterBody2D

var path_positions: Array = []
var current_index: int = 0
var speed: float = 200.0
var target: Vector2

func set_path(path: Array) -> void:
	path_positions = path
	if path_positions.size() > 0:
		current_index = 0
		global_position = path_positions[0]
		target = path_positions[0]

# maju n langkah
func move_steps(steps: int) -> void:
	if path_positions.size() == 0:
		return
	current_index = min(current_index + steps, path_positions.size() - 1)
	target = path_positions[current_index]

func _physics_process(delta: float) -> void:
	if path_positions.size() == 0:
		return
	if global_position.distance_to(target) > 5:
		var dir = (target - global_position).normalized()
		velocity = dir * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
