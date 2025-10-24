extends Object
class_name Bash

var thread: Thread
var _pipe: Pipe

var print_out_callback: Callable
var print_err_callback: Callable

var current_cmd: String

func _init(out_callback: Callable = Callable(), err_callback: Callable = Callable()) -> void:
	thread = Thread.new()
	print_out_callback = out_callback
	print_err_callback = err_callback
	_pipe = Pipe.new(OS.execute_with_pipe("/usr/bin/bash", PackedStringArray(), false))
	
	thread.start(_bash_process.bind(_pipe))

func _bash_process(pipe: Pipe) -> void:
	print_result.call_deferred("[ SHELL OPEN ]", print_out_callback)
	while pipe.stdio.is_open():
		_process_stdout(pipe)
		_process_stderr(pipe)
	print_result.call_deferred("[ SHELL CLOSE ]: {0}".format([pipe.stdio.get_error()]), print_out_callback)

func _process_stdout(pipe: Pipe) -> void:
	var line: String = pipe.stdio.get_line()
	if line.is_empty():
		return
	
	print_result.call_deferred(line, print_out_callback)

func _process_stderr(pipe: Pipe) -> void:
	var line: String = pipe.stderr.get_line()
	if line.is_empty():
		return
	
	if print_err_callback == null or print_err_callback.is_null():
		printerr("print_err_callback is null")
		return
	
	print_err_callback.call_deferred(line)

func print_result(txt: String, callback: Callable) -> void:
	if callback.is_null():
		return
	
	callback.call(txt)


func _process_cmd(pipe: Pipe) -> void:
	if current_cmd.is_empty():
		return
	
	if pipe.stdio.store_line(current_cmd):
		current_cmd = ""

func kill() -> void:
	if OS.is_process_running(_pipe.pid):
		OS.kill(_pipe.pid)
	_pipe.stdio.close()
	_pipe.stderr.close()
	thread.wait_to_finish()
	

func send_command(cmd: String) -> void:
	_pipe.stdio.store_line(cmd)
