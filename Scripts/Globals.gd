extends Node

func _ready():
	pass # Replace with function body.

func pause_game():
	get_tree().paused = true;
	
func unpause_game():
	get_tree().paused = false;

