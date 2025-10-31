@tool
extends Control

@onready var shell_rich_text_label: RichTextLabel = $VBoxContainer/ShellRichTextLabel
@onready var command_line_edit: LineEdit = $VBoxContainer/CommandLineEdit

var bash: Bash
var regex := RegEx.create_from_string("\\e\\[(?:([0-9]*);)?([0-9]*)m")

func print_output(txt: String):
	var formatted_text = PackedStringArray()
	
	var matchs: Array[RegExMatch] = regex.search_all(txt)
	var last_end: int = 0
	
	var reset_calls := PackedStringArray()
	for rmatch in matchs:
		formatted_text.append(txt.substr(last_end, rmatch.get_start()-last_end))
		var style = rmatch.get_string(1).to_int()
		var color = rmatch.get_string(2).to_int()
		
		match color:
			0:
				formatted_text.append_array(reset_calls)
				reset_calls.clear()
			30:
				formatted_text.append("[color=black]")
				reset_calls.append("[/color]")
			31:
				formatted_text.append("[color=red]")
				reset_calls.append("[/color]")
			32:
				formatted_text.append("[color=green]")
				reset_calls.append("[/color]")
			33:
				formatted_text.append("[color=yellow]")
				reset_calls.append("[/color]")
			34:
				formatted_text.append("[color=blue]")
				reset_calls.append("[/color]")
			35:
				formatted_text.append("[color=purple]")
				reset_calls.append("[/color]")
			36:
				formatted_text.append("[color=cyan]")
				reset_calls.append("[/color]")
			37:
				formatted_text.append("[color=white]")
				reset_calls.append("[/color]")
		
		last_end = rmatch.get_end()
	
	formatted_text.append(txt.substr(last_end) + "\n")
	#shell_rich_text_label.add_text(txt.replace(String.chr(0x1B), "\\e") + "\n")
	shell_rich_text_label.append_text("".join(formatted_text))

func print_error(txt: String):
	var err_color: Color = EditorInterface.get_editor_settings().get_setting("text_editor/theme/highlighting/comment_markers/critical_color")
	shell_rich_text_label.append_text("[color={0}]{1}[/color]\n".format([err_color.to_html(false), txt]))

func execute_command(cmd: String) -> void:
	assert(bash != null)
	bash.send_command(cmd)

func _on_command_line_edit_text_submitted(new_text: String) -> void:
	execute_command(new_text)
	command_line_edit.clear()
