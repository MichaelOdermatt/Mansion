extends KinematicBody

var path = []
var path_node = 0

var speed = 7
enum {
	WAITING,
	MOVING,
	ATTACKING
}

onready var nav = $"../Map/Navigation"
onready var player = $"../Player"
onready var state = MOVING

func _physics_process(delta):
	match state:
		ATTACKING, MOVING:
			move_along_path()
		WAITING:
			pass

func move_along_path():
	if path_node < path.size():
		var direction = (path[path_node] - global_transform.origin)
		if direction.length() < 1:
			path_node += 1
		else:
			move_and_slide(direction.normalized() * speed, Vector3.UP)

func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0

func _on_UpdatePathTimer_timeout():
	move_to(player.global_transform.origin)
