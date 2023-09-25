extends Node

var singleton_test : String

func _ready():
	singleton_test = "singleton_test"
	print("asserting this print is called only once")
