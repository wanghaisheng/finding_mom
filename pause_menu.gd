extends Node

signal resume
signal return_menu

func _on_resume_button_pressed():
	resume.emit()

func _on_settings_button_pressed():
	if $MainPauseMenu.visible:
		$MainPauseMenu.hide()
		$SettingsMenu.show()
	else:
		$MainPauseMenu.show()
		$SettingsMenu.hide()



func _on_quit_button_pressed():
	return_menu.emit()

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		_on_resume_button_pressed()
	pass
