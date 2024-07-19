extends CanvasLayer

signal resume
signal return_menu

func _on_resume_button_pressed():
	resume.emit()

func _on_settings_button_pressed():
	pass
	#TODO: show settings


func _on_quit_button_pressed():
	return_menu.emit()

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		resume.emit()
	pass
