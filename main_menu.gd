extends Node2D

var game = load("res://main_game.tscn")

func _ready():
	$SettingsMenu.load_settings()
	$SettingsMenu.apply_settings()

func _on_quit_button_pressed():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit(0)

func _on_play_button_pressed():
	get_tree().change_scene_to_packed(game)

func _on_settings_button_pressed():
	if $MainMenuCanvas.visible:
		$MainMenuCanvas.hide()
		$SettingsMenu.show()
	else:
		$MainMenuCanvas.show()
		$SettingsMenu.hide()

