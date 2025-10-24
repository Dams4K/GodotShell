@tool
extends Control

@onready var shell_rich_text_label: RichTextLabel = $VBoxContainer/ShellRichTextLabel
@onready var command_line_edit: LineEdit = $VBoxContainer/CommandLineEdit

var bash: Bash

func print_output(txt: String):
	shell_rich_text_label.add_text(txt + "\n")

func print_error(txt: String):
	var err_color: Color = EditorInterface.get_editor_settings().get_setting("text_editor/theme/highlighting/comment_markers/critical_color")
	shell_rich_text_label.append_text("[color={0}]{1}[/color]\n".format([err_color.to_html(false), txt]))

func execute_command(cmd: String) -> void:
	print_output("> {0}".format([cmd]))
	assert(bash != null)
	bash.send_command(cmd)

func _on_command_line_edit_text_submitted(new_text: String) -> void:
	execute_command(new_text)
	command_line_edit.clear()
