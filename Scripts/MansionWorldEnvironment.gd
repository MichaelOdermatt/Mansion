extends WorldEnvironment

var black = Color(0, 0, 0, 1)
var white = Color(1, 1, 1, 1)

func set_fire_effects():
	set_screen_effects()
	
func set_screen_effects():
	var current_environment = get_environment()
	current_environment.set_ambient_light_color(white)
	current_environment.set_ssao_enabled(true)
	set_environment(current_environment)
	
func remove_screen_effects():
	var current_environment = get_environment()
	current_environment.set_ambient_light_color(black)
	current_environment.set_ssao_enabled(false)
	set_environment(current_environment)
