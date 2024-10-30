extends CharacterBody2D 

# ---all signals we emit---
signal hit
signal shoot(bullet: Resource, direction: float, location: Vector2)
signal entered_portal
signal music_note(note)
signal freeze_frame(timeScale: float, duration: float)

# ---all variables needed---
@export var speed: float = 30000 # How fast the player will move (pixels/sec).
@export var roll_speed: float = 45000
@export var current_state = states.DEAD

var last_direction_rotation = 0

var PlayerBullet = preload("res://bullet.tscn")
var MusicNotes = preload("res://music_notes.tscn")
var show_flash = true
var right_music_note = true
var mouse_moved = false
var is_shooting = false

enum states {
	MOVE,
	PARRY,
	ROLL,
	DEAD,
	SHOOT,
}

func live_again():
	current_state = states.MOVE
	start_animations(Vector2.ZERO)

# ---functions---
func _ready():
	current_state = states.DEAD
	hide()
	$InvulnerableTimer.stop()

func start_animations(v: Vector2):
	if current_state == states.ROLL or current_state == states.PARRY:
			$Area2D/LegsSprite.play()
			$Area2D/BodySprite.play()
	elif current_state == states.MOVE or current_state == states.SHOOT:
		if v.length() > 0:
			$Area2D/LegsSprite.play()
			$Area2D/BodySprite.play()
		else:
			$Area2D/LegsSprite.stop()
			$Area2D/BodySprite.stop()

# should only be handling inputs correlating to movement and moving the cursor
func _process(delta):
	if !get_is_dead():
		
		var v = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		# set last_direction_rotation for rolling
		if v.normalized() != Vector2.ZERO:
			last_direction_rotation = atan2(v.normalized().y, v.normalized().x)

		var speed_used
		match current_state:
			states.MOVE, states.SHOOT:
				# might need to detect shooting here instead
				speed_used = speed
			states.PARRY:
				speed_used = speed
			states.ROLL:
				speed_used = roll_speed
			states.DEAD:
				speed_used = 0
		v = v.normalized() * speed_used * delta
		
		velocity = v
		move_and_slide()
		
		# animate if we have moved
		start_animations(v)
		
		var rotation_rads = atan2(v.y, v.x)
		
		# TODO: fix bug where after parry, timing between legs and body are unpaired
		# let the Legs update if in MOVE or PARRY. Let the Body update only in MOVE
		if v != Vector2.ZERO and (current_state == states.MOVE or current_state == states.SHOOT or current_state == states.PARRY):
			# need to figure out how much to rotate the player
			$Area2D/LegsSprite.set_rotation(rotation_rads)
			$Area2D/LegsSprite.animation = "walk"
			if current_state == states.MOVE:
				$Area2D/BodySprite.animation = "walk"
			elif current_state == states.SHOOT:
				$Area2D/BodySprite.animation = "shoot_walk"
		elif current_state == states.MOVE or current_state == states.SHOOT or current_state == states.PARRY:
			$Area2D/LegsSprite.animation = "stand"
			if current_state == states.MOVE:
				$Area2D/BodySprite.animation = "stand"
			elif current_state == states.SHOOT:
				$Area2D/BodySprite.animation = "shoot_stand"
		
		# aim for controller:
		var aim_direction = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
		
		# aim for mouse:
		var mouse_pos = get_global_mouse_position()
		var mouse_direction = mouse_pos - position
		
		# if we are aiming with a controller:
		if aim_direction != Vector2.ZERO:
			#hide the mouse
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			#show the cursor
			$Cursor.show()
			#project cursor to proper position
			var c_position = aim_direction.normalized() * 600
			$Cursor.position = c_position
			
			# rotate the rest of the body and music notes
			$Area2D/BodySprite.look_at(c_position + position)
			$Area2D/CollisionBox.look_at(c_position + position)
			$WallCollision.look_at(c_position + position)
			mouse_moved = false
			
		#elif we are aiming with the mouse
		elif mouse_direction != Vector2.ZERO and mouse_moved:
			$Area2D/BodySprite.look_at(get_global_mouse_position())
			$Area2D/CollisionBox.look_at(get_global_mouse_position())
			$WallCollision.look_at(get_global_mouse_position())

		# check current state and see what actions we can take
		match current_state:
			states.MOVE, states.SHOOT: # can shoot, parry, and roll
				if Input.is_action_just_pressed("shoot"):
					shoot_bullet($Area2D/BodySprite.rotation)
				if Input.is_action_just_pressed("parry"):
					current_state = states.PARRY
					parry()
				if Input.is_action_just_pressed("roll"):
					current_state = states.ROLL
					roll()
			states.PARRY: # can do ???
				pass
			states.ROLL: # cannot parry or shoot
				# change the body facing direction if we are currently rolling:
				$Area2D/BodySprite.set_rotation(last_direction_rotation)
				$Area2D/CollisionBox.set_rotation(last_direction_rotation)
				pass
			states.DEAD: # cannot do anything
				pass

# will handle event input
func _input(event):	
	# see if the mouse moved to display mouse and hide cursor:
	if event is InputEventMouseMotion:
		mouse_moved = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$Cursor.hide()

func roll():
	# reset all other actions:
	reset_shoot()
	set_collisions(0)
	$Area2D/BodySprite.animation = "roll"
	$Area2D/BodySprite.play()
	$Area2D/LegsSprite.play()
	$Area2D/LegsSprite.hide()
	
func set_collisions(c: int):
	$Area2D.collision_layer = c
	$Area2D.collision_mask = c
	
func set_parry_collisions(c: int):
	$ParryArea.collision_layer = c
	$ParryArea.collision_mask = c
	
func set_parry_all_collisions(c: int):
	$ParryAreaAll.collision_layer = c
	$ParryAreaAll.collision_mask = c

func shoot_bullet(rotation_rads):
	# generate a new bullet from the bullet_types in the right direction
	var pb = PlayerBullet.instantiate()
	pb.set_bullet(pb.bullet_types.PLAYER_BULLET)
	shoot.emit(pb, rotation_rads, position)
	current_state = states.SHOOT
	$ShootingAnimationTimer.start()
	#$ShootingAnimationTimer. # reset the timer
	return
	
func reset_shoot():
	$ShootingAnimationTimer.stop()
	
func parry():
	# reset all other actions:
	reset_shoot()
	set_parry_collisions(5)
	$ParryArea.rotation = $Area2D/BodySprite.rotation
	$Area2D/BodySprite.animation = "parry"
	$Area2D/BodySprite.play()
	$Area2D/LegsSprite.play()
	$ParryActiveTimer.start()
		
func start_invulnerability():
	set_collisions(0)
	$InvulnerableTimer.start()
	$VisibilityFlashTimer.start()
	_on_visibility_flash_timer_timeout()
	
func start(pos):
	position = pos
	show()
	$Area2D/CollisionBox.disabled = false

func get_is_dead():
	return current_state == states.DEAD
	
func set_is_dead(d: bool):
	if d:
		current_state = states.DEAD
		$Area2D/BodySprite.play("death")
		$Area2D/LegsSprite.hide()
	else:
		current_state = states.MOVE
		$Area2D/LegsSprite.show()

func _on_invulnerable_timer_timeout():
	$VisibilityFlashTimer.stop()
	set_collisions(5)
	$Area2D/BodySprite.modulate = Color(1, 1, 1, 1)
	$Area2D/LegsSprite.modulate = Color(1, 1, 1, 1)
	show_flash = true
	
func _on_visibility_flash_timer_timeout():
	show_flash = !show_flash
	if show_flash:
		$Area2D/BodySprite.modulate = Color(1, 1, 1, 1)
		$Area2D/LegsSprite.modulate = Color(1, 1, 1, 1)
	else:
		$Area2D/BodySprite.modulate = Color(1, 1, 1, 0.6)
		$Area2D/LegsSprite.modulate = Color(1, 1, 1, 0.2)

# emit the music note to the game
func _on_music_note_timer_timeout():
	if current_state != states.DEAD:
		var note = MusicNotes.instantiate()
		var location
		if right_music_note:
			location = $Area2D/BodySprite/RightSide.global_position
		else:
			location = $Area2D/BodySprite/LeftSide.global_position
		right_music_note = !right_music_note
		note.position = location
		music_note.emit(note)

func _on_area_2d_body_entered(body):
	if $InvulnerableTimer.is_stopped() and current_state != states.ROLL and current_state != states.DEAD:
		if body.is_in_group("player_bullets"):
			pass
		elif body.is_in_group("enemy_bullets"):
			lose_life()
			body.collide_with_target() # used to remove the bullet
		elif body.is_in_group("enemies"):
			lose_life()
		elif body.is_in_group("portals"):
			entered_portal.emit()
		else:
			pass

func lose_life():
	hit.emit()
	freeze_frame.emit(0.1, 0.3)
	start_invulnerability()

#reset everything after an animation is finished
func _on_body_sprite_animation_finished():
	if $Area2D/BodySprite.animation == "parry" and current_state == states.PARRY:
		$Area2D/BodySprite.animation = "stand"
		current_state = states.MOVE
	elif $Area2D/BodySprite.animation == "roll" and current_state == states.ROLL:
		$Area2D/BodySprite.animation = "stand"
		current_state = states.MOVE
		$Area2D/LegsSprite.show()
		set_collisions(5)
	pass

func _on_parry_area_body_entered(body):
	if body.is_in_group("enemy_bullets"):
		freeze_frame.emit(.1, 0.37)
		set_parry_all_collisions(4)
		$ParrySuccessTimer.start()
		pass

func _on_parry_area_all_body_entered(body):
	if body.is_in_group("bullets"):
		body.parried()

func _on_parry_success_timer_timeout():
	set_parry_all_collisions(0)
	$ParrySuccessTimer.stop()

func _on_parry_active_timer_timeout():
	set_parry_collisions(0)
	$ParryActiveTimer.stop()


func _on_shooting_animation_timer_timeout():
	current_state = states.MOVE
	$ShootingAnimationTimer.stop()
