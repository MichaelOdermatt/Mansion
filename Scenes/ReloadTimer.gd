extends Timer

onready var progress_bar = $"../TextureProgress"

func _process(delta):
	var percent_complete = (1 - time_left/wait_time) * 100
	progress_bar.value = percent_complete
