extends KinematicBody

var path = []
var path_node = 0
var wander_pos_index : int
var path_waypoint

var speed = 7
enum {
	WAITING,
	MOVING,
	ATTACKING
}

onready var nav = $"../Map/Navigation"
onready var player = $"../Player"
onready var move_to_player_timer = $"UpdatePathToPlayerTimer"
onready var state = null
onready var wander_pos = [
	$"WanderPos1".global_transform.origin,
	$"WanderPos2".global_transform.origin,
	$"WanderPos3".global_transform.origin,
	$"WanderPos4".global_transform.origin
]
onready var rng = RandomNumberGenerator.new()

# start the UpdatePathToPlayerTimer to start moving towards the player
# stop the UpdatePathToPlayerTimer and randomy set the waypoint to wander

func _ready():
	var wander_pos_index = 0
	var path_waypoint = null
	wait()

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

func set_random_waypoint():
	rng.randomize()
	var new_wander_pos_index = rng.randi_range(0, 3)
	
	# ensure the newly generated waypoint is not the current waypoint
	if new_wander_pos_index == wander_pos_index:
		new_wander_pos_index += 1 
		if new_wander_pos_index > 3:
			new_wander_pos_index = 0
	wander_pos_index = new_wander_pos_index
	
	path_waypoint = wander_pos[wander_pos_index]

func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0

func update_waypoint_from_state():
	match state:
		ATTACKING:
			path_waypoint = player.global_transform.origin
		MOVING:
			set_random_waypoint()
		WAITING:
			path_waypoint = global_transform.origin

func _on_UpdatePathToPlayerTimer_timeout():
	move_to(player.global_transform.origin)

func attack():
	move_to_player_timer.start()
	state = ATTACKING
	
func wander():
	if !move_to_player_timer.is_stopped():
		move_to_player_timer.stop()
	set_random_waypoint()
	move_to(path_waypoint)
	state = MOVING

func wait():
	if !move_to_player_timer.is_stopped():
		move_to_player_timer.stop()
	path_waypoint = global_transform.origin
	move_to(path_waypoint)
	state = WAITING
