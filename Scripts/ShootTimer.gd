extends Timer

onready var world_environment = $"../../WorldEnvironment"
onready var player = $".."
onready var player_camera_sound = $"../CameraSound"
onready var player_ray_cast = $"../Camera/PlayerRayCast"
onready var player_ray_cast_draw = $"../Camera/Line2D"
onready var reload_timer = $"../ReloadTimer"
var is_firing = false

func fire():
	player_camera_sound.play()
	world_environment.set_screen_effects()
	Globals.pause_game()
	player_ray_cast_draw.draw_raycast_line()
	#DrawLine3d.DrawLine(Vector3(0, 0, 0), player_ray_cast.collision_point,  Color( 1, 0, 0, 1 ), 1)
	is_firing = true
	start()

func _on_ShootTimer_timeout():
	is_firing = false
	world_environment.remove_screen_effects()
	player_ray_cast_draw.remove_raycast_line()
	Globals.unpause_game()
	reload_timer.start()
