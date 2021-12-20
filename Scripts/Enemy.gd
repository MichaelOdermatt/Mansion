extends KinematicBody

var path = []
var path_node = 0
var wander_pos_index : int = 0
var wander_pos_path = null
var reached_destination_threshold = 1.2

var speed = 7
enum {
	WAIT,
	WANDER,
	ATTACK
}

onready var nav = $"../Map/Navigation"
onready var player = $"../Player"
onready var path_to_player_timer = $"PathToPlayerTimer"
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
	wander()

func _physics_process(delta):
	match state:
		ATTACK:
			move_along_path()
		WANDER:
			move_along_path()
			wait_if_destination_reached()
		WAIT:
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
	wander_pos_path = wander_pos[wander_pos_index]

func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0
	
func _on_PathToPlayerTimer_timeout():
	move_to(player.global_transform.origin)

func attack():
	if state != ATTACK:
		path_to_player_timer.start()
		state = ATTACK
	
func wander():
	if state != WANDER:
		stop_path_to_player_timer()
		set_random_waypoint()
		move_to(wander_pos_path)
		state = WANDER

func wait():
	if state != WAIT:
		stop_path_to_player_timer()
		state = WAIT

func stop_path_to_player_timer():
	if !path_to_player_timer.is_stopped():
		path_to_player_timer.stop()

# check if enemy has reached its destination, if so then wait
func wait_if_destination_reached():
	if global_transform.origin.distance_to(wander_pos_path) <= reached_destination_threshold:
		state = WAIT
