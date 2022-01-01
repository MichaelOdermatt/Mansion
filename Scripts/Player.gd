extends KinematicBody

export var mouse_sensitivity : float = 8
export var movement_speed : float = 6
export var height_reset_speed : float = 0.5
export var min_height : float = 2.6
export var max_height : float = 3.4
export var min_view_angle : float = -70
export var max_view_angle : float = 70

var enemy_collision_distance_treshold = 2.75
var is_moving : bool = false
var is_dead : bool = false
var mid_height : float = (min_height + max_height) /2
onready var camera = $Camera
onready var shoot_timer = $"ShootTimer"
onready var reload_timer = $"ReloadTimer"
onready var enemy = $"../Enemy"
onready var mouse_delta : Vector2 = Vector2()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if_exit_pressed_quit_game()
	
	if is_dead:
		return
	
	# set mouse delta, mouse delta is used for player and camera rotation
	var mouse_motion = event as InputEventMouseMotion
	if mouse_motion:
		mouse_delta = event.relative
		
	if Input.is_action_just_pressed("shoot"):
		if (!shoot_timer.is_firing && reload_timer.is_stopped()):
			shoot_timer.fire()

func _physics_process(delta):
	if is_dead:
		fall_down()
		return
	
	rotate_player(delta)
	
	var movement_vector : Vector3
	var forward_movement : Vector3
	var sideways_movement : Vector3
	
	is_moving = false
	
	if Input.is_action_pressed("move_fwd"):
		forward_movement = -transform.basis.z
		is_moving = true
	if Input.is_action_pressed("move_bwd"):
		forward_movement = transform.basis.z
		is_moving = true
	if Input.is_action_pressed("move_l"):
		sideways_movement = -transform.basis.x
		is_moving = true
	if Input.is_action_pressed("move_r"):
		sideways_movement = transform.basis.x
		is_moving = true
	
	movement_vector = forward_movement + sideways_movement
	
	#movement_vector.y = float_back_to_mid_height()
	#clamp_player_height()
	
	var distance_to_enemy = enemy.global_transform.origin.distance_to(global_transform.origin)
	print(distance_to_enemy)
	if distance_to_enemy <= enemy_collision_distance_treshold:
		is_dead = true
	
	move_and_slide(movement_vector * movement_speed, Vector3(0, 1, 0))

func if_exit_pressed_quit_game():
	if Input.is_action_pressed("key_exit"):
		get_tree().quit()

func float_back_to_mid_height():
	var y = self.global_transform.origin.y
	var vertical_velociy = lerp(y, mid_height, height_reset_speed) - y
	return vertical_velociy

func clamp_player_height():
	var height = self.global_transform.origin.y
	self.global_transform.origin.y = clamp(height, min_height, max_height)

func rotate_player(delta):
	# create variables which hold the camera rotation on the x axis and player rotation on the y
	var change_in_x = mouse_delta.y * mouse_sensitivity * delta
	var change_in_y = mouse_delta.x * mouse_sensitivity * delta
	
	var camera_rotation_x = camera.rotation_degrees.x - change_in_x
	var player_rotation_y = rotation_degrees.y - change_in_y
	
	# clamp the camera rotation so you cant rotate all the way around the x axis
	camera_rotation_x = clamp(camera_rotation_x, min_view_angle, max_view_angle)
	
	# apply the rotation variables to the camera and player
	camera.rotation_degrees.x = camera_rotation_x
	self.rotation_degrees.y = player_rotation_y
	
	# reset the mouse delta so the rotation will stop
	mouse_delta = Vector2()

func fall_down():
	var current_rotation = Quat(transform.basis)
	var target_rotation = Quat(Vector3(0,0,1), 1)
	var new_rotation = current_rotation.slerp(target_rotation, 0.01)
	transform.basis = Basis(new_rotation)
	
	pass
