extends Line2D

onready var Cam = $".."
onready var ray_cast = $"../PlayerRayCast"
onready var shoot_timer = $"../../ShootTimer"
var screen_center = Vector2(320,280)

# Called when the node enters the scene tree for the first time.
func _process(delta):
	if shoot_timer.is_firing:
		match_line_end_point()

func draw_raycast_line():
	var line_end = ray_cast.collision_point
	var screen_point_line_end = null
	
	if (line_end != null):
		screen_point_line_end = Cam.unproject_position(line_end)
	else:
		screen_point_line_end = screen_center
	
	add_point(screen_point_line_end)

func remove_raycast_line():
	remove_point(1)

func match_line_end_point():
	var line_end = ray_cast.collision_point
	var screen_point_line_end = null
	
	if (line_end != null):
		screen_point_line_end = Cam.unproject_position(line_end)
	else:
		screen_point_line_end = screen_center
	
	if get_point_position(1) != screen_point_line_end:
		set_point_position(1, screen_point_line_end)
