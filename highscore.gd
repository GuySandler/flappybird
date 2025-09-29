extends Node

var highscore: int = 0
var night: bool = false

func set_score(value: int) -> void:
	highscore = value
func get_score() -> int:
	return highscore
func set_mode(value: int) -> void:
	night = value
func get_mode() -> bool:
	return night
