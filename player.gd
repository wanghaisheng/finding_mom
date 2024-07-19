extends CharacterBody2D 

# ---all signals we emit---
signal hit
signal shoot(bullet, direction, location)
signal entered_portal
signal music_note

@onready var animationTree = $AnimationTree;
@onready var animationState = animationTree.get("parameters/playback");

# ---all variables needed---
@export var speed: float = 400 # How fast the player will move (pixels/sec).
@export var roll_speed: float = 600

@export var _run_speed: float = 100;
@export var _acceleration: float = 500;
@export var _friction: float = 500;

var input_vector = Vector2.ZERO


var screen_size # Size of the game window.
var PlayerBullet = preload("res://player_bullet.tscn")
var MusicNotes = preload("res://music_notes.tscn")
var is_dead = false
var show_flash = true
var right_music_note = true
var mouse_moved = false

enum states {
	MOVE,
	ROLL,
	DEAD,
}
var current_state = states.DEAD

func live_again():
	current_state = states.MOVE
	start_animations(Vector2.ZERO)

# ---functions---
func _ready():
	screen_size = get_viewport_rect().size
	current_state = states.DEAD
	hide()
	$InvulnerableTimer.stop()
	animationTree.active = true

func start_animations(v):
	if current_state == states.ROLL:
			$Area2D/LegsSprite.play()
			$Area2D/BodySprite.play()
	else:		
		if v.length() > 0:
			$Area2D/LegsSprite.play()
			$Area2D/BodySprite.play()
		else:
			$Area2D/LegsSprite.stop()
			$Area2D/BodySprite.stop()

# should only be handling inputs correlating to movement and moving the cursor
func _process(delta):
	if !is_dead:
		
		var v = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		# set input_vector for rolling
		if v.normalized() != Vector2.ZERO:
			input_vector = v.normalized()

		var speed_used
		match current_state:
			states.MOVE:
				speed_used = speed
			states.ROLL:
				speed_used = roll_speed
			states.DEAD:
				speed_used = 0
		v = v.normalized() * speed_used * delta
		#position += v * delta
		
		move_and_collide(v)
		#check for max dimensions:
		#position = position.clamp(Vector2.ZERO, screen_size)
		
		animationTree.set("parameters/Walk/blend_position", input_vector);
		
		# animate if we have moved
		start_animations(v)
		
		var rotation_rads = atan2(v.y, v.x)
		
		if v != Vector2.ZERO and current_state != states.ROLL:
			# need to figure out how much to rotate the player
			$Area2D/LegsSprite.set_rotation(rotation_rads)
			$Area2D/LegsSprite.animation = "walk"
			$Area2D/BodySprite.animation = "walk"
		elif current_state != states.ROLL:
			$Area2D/LegsSprite.animation = "stand"
			$Area2D/BodySprite.animation = "stand"
		
		# aim for controller:
		var aim_direction = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
		var aim_rads = atan2(aim_direction.y, aim_direction.x)
		
		# aim for mouse:
		var mouse_pos = get_global_mouse_position()
		var mouse_direction = mouse_pos - position
		var mouse_rads = atan2(mouse_direction.y, mouse_direction.x)
		
		# if we are aiming with a controller:
		if aim_direction != Vector2.ZERO:
			#hide the mouse
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			#show the cursor
			$Cursor.show()
			#project cursor to proper position
			var c_position = aim_direction.normalized() * 400
			$Cursor.position = c_position
			
			# rotate the rest of the body and music notes
			$Area2D/BodySprite.look_at(c_position + position)
			$Area2D/CollisionBox.look_at(c_position + position)
			mouse_moved = false
			
		#elif we are aiming with the mouse
		elif mouse_direction != Vector2.ZERO and mouse_moved:
			$Area2D/BodySprite.look_at(get_global_mouse_position())
			$Area2D/CollisionBox.look_at(get_global_mouse_position())
			# TODO: fix music notes when aiming with mouse
			
# will handle event input
func _input(event):	
	# see if the mouse moved to display mouse and hide cursor:
	if event is InputEventMouseMotion:
		mouse_moved = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$Cursor.hide()

	# check current state and see what actions we can take
	if current_state == states.MOVE:
		if event.is_action_pressed("shoot"):
			shoot_bullet($Area2D/BodySprite.rotation)
		if event.is_action_pressed("parry"):
			parry()
		if event.is_action_pressed("roll"):
			current_state = states.ROLL
			roll()
	elif current_state == states.ROLL:
		pass
	elif current_state == states.DEAD:
		pass

#func _physics_process(delta):
	#if input_vector == Vector2.ZERO:
		#animationTree.set("parameters/Idle/blend_position", input_vector)
		#animationState.travel("Idle")
	#match current_state:
		##states.MOVE:
			##move(delta)
		#states.ROLL:
			#roll()
			
func roll():
	#var _roll_vector = input_vector
	#velocity = _roll_vector * roll_speed
	print("rolling")
	animationTree.set("parameters/Roll/blend_position", input_vector)
	animationState.travel("Roll")
	$Area2D/BodySprite.animation = "roll"
	$Area2D/BodySprite.play()
	$Area2D/LegsSprite.play()
	$Area2D/LegsSprite.hide()
	#move_and_slide();
	# play animation and move
	#$AnimationPlayer.play("roll")
	# This will be used in the roll() function.
	# This will be used to determine which direction the player should roll.

func shoot_bullet(rotation_rads):
	# find the weapon we are shooting
	# generate a new bullet in the right direction
	shoot.emit(PlayerBullet, rotation_rads, position)
	#shoot.emit(PlayerBullet, rotation_rads, $BodySprite/RightSide.position)
	return
	
func parry():
	print("parry")
	pass
	

#TODO: might need to keep a tally of everything that is inside so that when we become vulnerable again we take damage
func _on_body_exited(body):
	print('exit')
	pass

func _on_body_entered(body):
	if $InvulnerableTimer.is_stopped() and current_state == states.MOVE:
		if body.is_in_group("player_bullets"):
			pass
		elif body.is_in_group("enemies"):
			# TODO: calculate damage and send that in emit
			hit.emit()
			# Must be deferred as we can't change physics properties on a physics callback.
			#$CollisionBox.set_deferred("disabled", true)
			start_invulnerability()
		elif body.is_in_group("portals"):
			entered_portal.emit()
		else:
			pass
		
func start_invulnerability():
	$InvulnerableTimer.start()
	$VisibilityFlashTimer.start()
	_on_visibility_flash_timer_timeout()
	
func start(pos):
	position = pos
	show()
	$Area2D/CollisionBox.disabled = false

func get_is_dead():
	return is_dead
	
func set_is_dead(d):
	is_dead = d
	if d:
		hide()
	else:
		show()

func _on_invulnerable_timer_timeout():
	$VisibilityFlashTimer.stop()
	show()
	show_flash = true
	

# TODO: fix the flashing
func _on_visibility_flash_timer_timeout():
	show_flash = !show_flash
	if show_flash:
		show()
	else:
		hide()


func _on_music_note_timer_timeout():
	# TODO: figure out how to leave the music notes at each position
	var note = MusicNotes.instantiate()
	if right_music_note:
		note.global_position = $Area2D/BodySprite/RightSide.global_position - position
	else:
		note.global_position = $Area2D/BodySprite/LeftSide.global_position - position
	right_music_note = !right_music_note
	add_child(note)
	music_note.emit()


func _on_area_2d_body_entered(body):
	if $InvulnerableTimer.is_stopped():
		if body.is_in_group("player_bullets"):
			pass
		elif body.is_in_group("enemies"):
			# TODO: calculate damage and send that in emit
			hit.emit()
			# Must be deferred as we can't change physics properties on a physics callback.
			#$CollisionBox.set_deferred("disabled", true)
			start_invulnerability()
		elif body.is_in_group("portals"):
			entered_portal.emit()
		else:
			pass


#reset everything after an animation is finished
func _on_body_sprite_animation_finished():
	if $Area2D/BodySprite.animation == "roll":
		$Area2D/BodySprite.animation = "stand"
		current_state = states.MOVE
		$Area2D/LegsSprite.show()
	pass
