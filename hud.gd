extends CanvasLayer

signal player_die

var total_hearts = 5
var current_health = 5

var total_bullets = 3
var current_bullets = 3

var current_level = 0

var score = 0

var full_heart = load("res://Assets/Icons/heart.png")
var empty_heart = load("res://Assets/Icons/empty_heart.png")

var bullet = load("res://Assets/Bullets/basic_bullet.png")
var empty_bullet = load("res://Assets/Bullets/basic_empty_bullet.png")

signal start_game
signal level_complete
signal quit_game
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

	#TODO: show back button to main menu
	$StartButton.show()
	$QuitButton.show()
	
func show_start():
	$StartButton.show()
	$QuitButton.show()

func _on_start_button_pressed():
	$StartButton.hide()
	$QuitButton.hide()
	start_game.emit()
	#current_health = 1
	#total_hearts = 1
	display_hearts()
	# TODO: make sure we reset the score and start it again BUG
	$ScoreTimer.start()	
	restart_score()

func _on_message_timer_timeout():
	$Message.hide()
	
func display_level():
	$LevelLabel.show()
	
func hide_level():
	$LevelLabel.hide()

func next_level():
	current_level += 1
	$LevelLabel.text = "Level " + String.num_int64(current_level)
	
func get_level():
	return current_level
	
func restart_level():
	current_level = 0
	
func reset_health():
	# might need to reset total hearts as well if we end up giving more hearts
	current_health = total_hearts
	
func lose_heart():
	current_health -= 1
	display_hearts()
	if current_health <= 0:
		restart_level()
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
		
func reset_all_bullets():
	current_bullets = total_bullets
	display_bullets()

func reclaim_bullet():
	current_bullets += 1
	if current_bullets > total_bullets:
		current_bullets = total_bullets
	display_bullets()
	
func shoot_bullet():
	if current_bullets >= 1:
		current_bullets -= 1
		display_bullets()
		return true
	return false
		
func display_bullets():
	# clear all bullets
	var bullets = $BulletArea.get_children()
	for bullet in bullets:
		bullet.queue_free()
		
	
	# add each bullet
	for i in range(total_bullets):
		var b = Area2D.new()
		var sprite = Sprite2D.new()
		if i < current_bullets:
			sprite.set_texture(bullet)
		else:
			sprite.set_texture(empty_bullet)
		#figure out display offset
		var position = Vector2.ZERO
		position.x = i * 100 + 50
		position.y = -50
		sprite.position = position
		var scale = Vector2.ZERO
		scale.x = 5
		scale.y = 5
		sprite.scale = scale
		b.add_child(sprite)
		$BulletArea.add_child(b)

func update_score():
	$ScoreLabel.text = str(score)
	if score >= 60: #TODO: reset to 60
		show_message("Complete")
		$ScoreTimer.stop()
		reset_all_bullets()
		level_complete.emit()

func _on_score_timer_timeout():
	score += 1
	update_score()
	
func restart_score():
	score = 0
	update_score()
	
func stop():
	$ScoreTimer.stop()


func _on_quit_button_pressed():
	quit_game.emit()
