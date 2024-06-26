extends CanvasLayer

signal player_die

var total_hearts = 1
var current_health = 1

var full_heart = load("res://Assets/Icons/heart.png")
var empty_heart = load("res://Assets/Icons/empty_heart.png")

signal start_game
# Called when the node enters the scene tree for the first time.
func _ready():
	# need to create health and set to healthy
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	$Message.text = "Dodge the Creeps!"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

func update_score(score):
	$ScoreLabel.text = str(score)


func _on_start_button_pressed():
	$StartButton.hide()
	start_game.emit()
	current_health = 1
	total_hearts = 3
	display_hearts()

func _on_message_timer_timeout():
	$Message.hide()
	
func lose_heart():
	current_health -= 1
	
	display_hearts()
	print(current_health)
	
	if current_health <= 0:
		player_die.emit()
		
func display_hearts():
	# clear all hearts
	var hearts = $HeartArea.get_children()
	for heart in hearts:
		heart.queue_free()
		
	
	# add each heart
	for i in range(total_hearts):
		var h = Area2D.new()
		var sprite = Sprite2D.new()
		if i < current_health:
			sprite.set_texture(full_heart)
		else:
			sprite.set_texture(empty_heart)
		#figure out display offset
		var position = Vector2.ZERO
		position.x = i * 100 + 50
		position.y = 50
		sprite.position = position
		var scale = Vector2.ZERO
		scale.x = 5
		scale.y = 5
		sprite.scale = scale
		h.add_child(sprite)
		$HeartArea.add_child(h)
