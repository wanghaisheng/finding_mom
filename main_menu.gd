extends Node2D


func _on_quit_button_pressed():
	print("Quit")
	# TODO: catch the notification with a confirmation box
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit(0)



func _on_play_button_pressed():
	print("Play")
	var node = Node
	node.set
	get_tree().change_scene_to_file("res://demo_game.tscn") # try using change_scene_to_packed

func _on_settings_button_pressed():
	if $MainMenuCanvas.visible:
		$MainMenuCanvas.hide()
		$SettingsMenu.show()
	else:
		$MainMenuCanvas.show()
		$SettingsMenu.hide()
	print("Settings")
