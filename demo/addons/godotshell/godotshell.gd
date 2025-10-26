@tool
extends EditorPlugin

var shell_dock: Control
var bash: Bash


func _enter_tree() -> void:
	shell_dock = preload("res://addons/godotshell/shell_dock.tscn").instantiate()
	bash = Bash.new(shell_dock.print_output, shell_dock.print_error)
	shell_dock.bash = bash
	
	add_control_to_bottom_panel(shell_dock, "Shell")


func _exit_tree() -> void:
	remove_control_from_bottom_panel(shell_dock)
	shell_dock.free()
	bash.kill()
	bash.free()
