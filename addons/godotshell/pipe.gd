extends RefCounted
class_name Pipe

var stdio: FileAccess
var stderr: FileAccess
var pid: int

## Pipe.new(OS.execute_with_pipe(...))
func _init(data: Dictionary) -> void:
	stdio = data.stdio
	stderr = data.stderr
	pid = data.pid
