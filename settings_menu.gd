extends CanvasLayer

signal back_button_pressed

var selectedResolution = ""
var selectedViewportMode = ""

var config = ConfigFile.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	# select the settings from the loaded settings
	# then apply all of the settings
	# make sure all settings values are set and not blank when displaying the menu
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func apply_settings():
	_on_apply_button_pressed()

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
		"Exclusive Fullscreen":
			windowMode = Window.MODE_EXCLUSIVE_FULLSCREEN
	get_tree().root.mode = windowMode
	#TODO: get the volume changing working or remove it?
	
	save_config(selectedResolution, selectedViewportMode)
	
func save_config(resolution, viewport_mode):
	config.set_value("Settings", "resolution", resolution)
	config.set_value("Settings", "viewport_mode", viewport_mode)
	
	config.save("./settings.cfg")
	
func load_settings():
	var err = config.load("./settings.cfg")
	if err != OK:
		return
		
	for setting in config.get_sections():
		selectedResolution = config.get_value("Settings", "resolution")
		selectedViewportMode = config.get_value("Settings", "viewport_mode")
		
	# next find the index of what they are and select them with this:
	$ResolutionList.select(0)
	$ViewportModeList.select(0)
	for i in $ResolutionList.item_count:
		if $ResolutionList.get_item_text(i) == selectedResolution:
			$ResolutionList.select(i)
	for i in $ViewportModeList.item_count:
		if $ViewportModeList.get_item_text(i) == selectedViewportMode:
			$ViewportModeList.select(i)

func _on_resolution_list_item_selected(index):
	selectedResolution = $ResolutionList.get_item_text(index)


func _on_viewport_mode_list_item_selected(index):
	selectedViewportMode = $ViewportModeList.get_item_text(index)


func _on_back_button_pressed():
	back_button_pressed.emit()
