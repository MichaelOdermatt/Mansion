extends KinematicBody

var path = []
var path_node = 0
var wander_pos_index : int = 0
var wander_pos_path = null
var reached_destination_threshold = 1.2
var has_fired
export var player_detection_fov = 15
export var player_detection_distance = 8
export var chance_enemy_will_attack_when_spotted : float = 25 #percent
export var speed = 7

enum {
	WAIT,
	WANDER,
	ATTACK,
	DEAD
}

onready var nav = $"../Map/Navigation"
onready var player = $"../Player"
onready var path_to_player_timer = $"PathToPlayerTimer"
onready var animation_tree = $"Enemy/AnimationTree"
onready var player_raycast = $"../Player/Camera/PlayerRayCast"
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
	wait()

func _physics_process(delta):
	match state:
		ATTACK:
			set_anim_run()
			move_along_path()
		WANDER:
			set_anim_run()
			move_along_path()
			wait_if_destination_reached()
		WAIT:
			set_anim_idle()
			wander_or_attack_if_spotted()
		DEAD:
			set_anim_idle()

func _input(event):
	# if player shoots and enemy waiting, wander or attack
	if Input.is_action_just_pressed("shoot"):
		if state == WAIT:
			wander_or_attack()
		if player_raycast.collision_object == self:
			player_raycast.collision_object = null
			dead()

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
	look_at(target_pos, Vector3.UP)
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

func dead():
	stop_path_to_player_timer()
	state = DEAD

func stop_path_to_player_timer():
	if !path_to_player_timer.is_stopped():
		path_to_player_timer.stop()

# check if enemy has reached its destination, if so then wait
func wait_if_destination_reached():
	if global_transform.origin.distance_to(wander_pos_path) <= reached_destination_threshold:
		state = WAIT

func is_enemy_spotted():
	var player_dir = player.global_transform.basis.z * -1
	var enemy_to_player_vector = (get_translation() - player.get_translation()).normalized()

	if acos(enemy_to_player_vector.dot(player_dir)) <= deg2rad(player_detection_fov):
		return true
	else:
		return false
		
func is_player_near():
	var player_location = player.global_transform.origin
	var enemy_location = global_transform.origin
	if enemy_location.distance_to(player_location) <= player_detection_distance:
		return true
	else:
		return false

func wander_or_attack_if_spotted():
	if is_enemy_spotted() || is_player_near(): 
		wander_or_attack()
			
func wander_or_attack():
	rng.randomize()
	var chance = rng.randf() + 0.01
	if chance <= chance_enemy_will_attack_when_spotted/100:
		attack()
	else:
		wander()

func set_anim_run():
	animation_tree.set("parameters/Blend2/blend_amount", 1)

func set_anim_idle():
	animation_tree.set("parameters/Blend2/blend_amount", 0)
