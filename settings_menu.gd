extends CanvasLayer

signal back_button_pressed

var selectedResolution = ""
var selectedViewportMode = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	# select the settings from the loaded settings
	$ResolutionList.select(0)
	$ViewportModeList.select(0)
	# then apply all of the settings
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_apply_button_pressed(): 
	var sizes = selectedResolution.split(" X ", false, 2)
	get_tree().root.size = Vector2i(int(sizes[0]), int(sizes[1]))
	
	var windowMode = Window.MODE_EXCLUSIVE_FULLSCREEN
	match selectedViewportMode:
		"Maximized":
			windowMode = Window.MODE_MAXIMIZED
		"Minimized":
			windowMode = Window.MODE_MINIMIZED
		"Windowed":
			windowMode = Window.MODE_WINDOWED
		"Fullscreen":
			windowMode = Window.MODE_FULLSCREEN
	get_tree().root.mode = windowMode
	
	#TODO: get the volume changing working


func _on_resolution_list_item_selected(index):
	selectedResolution = $ResolutionList.get_item_text(index)


func _on_viewport_mode_list_item_selected(index):
	selectedViewportMode = $ViewportModeList.get_item_text(index)


func _on_back_button_pressed():
	back_button_pressed.emit()
