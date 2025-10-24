@abstract
extends RefCounted
class_name ShellColorConverter

var text: String

func _init(text: String) -> void:
	self.text = text

@abstract func to_bbcode() -> String
