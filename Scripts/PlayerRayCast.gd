extends RayCast

var collision_point = null
var collision_object = null

func _process(delta):
	if is_colliding():
		collision_object = get_collider()
		collision_point = get_collision_point()
	else:
		collision_point = null
		collision_object = null
