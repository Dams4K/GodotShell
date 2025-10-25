extends Object
class_name Bash

var _thread: Thread
var _pipe: Pipe

var out_callback: Callable = Callable()
var err_callback: Callable = Callable()

var current_cmd: String

func _init(out_callback: Callable = Callable(), err_callback: Callable = Callable()) -> void:
	_thread = Thread.new()
	self.out_callback = out_callback
	self.err_callback = err_callback
	
	#_pipe = Pipe.new(OS.execute_with_pipe("script", ["--quiet", "--return", "--command", "bash", "/dev/null"], false))
	#_pipe = Pipe.new(OS.execute_with_pipe("stdbuf", ["-oL", "-eL", "bash", "-i"], false))
	_pipe = Pipe.new(OS.execute_with_pipe("bash", ["-i"], false))
	_pipe.stdio.store_line("export TERM=xterm-256color")
	_pipe.stdio.store_line("source ~/.bashrc")
	_thread.start(_bash_process.bind(_pipe))

func _bash_process(pipe: Pipe) -> void:
	print_result.call_deferred("[ SHELL OPEN ]", out_callback)
	while pipe.stdio.is_open():
		_process_stdout(pipe)
		_process_stderr(pipe)
	print_result.call_deferred("[ SHELL CLOSE ]: {0}".format([pipe.stdio.get_error()]), out_callback)

func _process_stdout(pipe: Pipe) -> void:
	var line: String = pipe.stdio.get_line()
	if line.is_empty():
		return
	
	print_result.call_deferred(line, out_callback)

func _process_stderr(pipe: Pipe) -> void:
	var line: String = pipe.stderr.get_line()
	if line.is_empty():
		return
	print(line)
	print_result.call_deferred(line, err_callback)

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
	if _thread != null and _thread.is_alive():
		_thread.wait_to_finish()
	

func send_command(cmd: String) -> void:
	_pipe.stdio.store_line(cmd)
	_pipe.stdio.flush()
