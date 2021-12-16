extends RayCast

var collision_point = null

func _process(delta):
	if is_colliding():
		collision_point = get_collision_point()
	else:
		collision_point = null
