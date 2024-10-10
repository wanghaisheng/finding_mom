extends Node2D

signal exited
signal entered


func _on_visible_on_screen_notifier_2d_screen_entered():
	entered.emit()

func _on_visible_on_screen_notifier_2d_screen_exited():
	exited.emit()
	
