extends Area2D

# ---all signals we emit---
signal hit
signal shoot(bullet, direction, location)

# ---all variables needed---
@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var PlayerBullet = preload("res://player_bullet.tscn")

# ---functions---
func _ready():
	screen_size = get_viewport_rect().size

	hide()


func _process(delta):
	var velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$LegsSprite.play()
		$BodySprite.play()
	else:
		$LegsSprite.stop()
		$BodySprite.stop()
	
	position += velocity * delta
	
	#check for max dimensions:
	position = position.clamp(Vector2.ZERO, screen_size)
	
	var rotation_rads = atan2(velocity.y, velocity.x)
	
	if velocity.x != 0 or velocity.y != 0:
		# need to figure out how much to rotate the player
		$LegsSprite.set_rotation(rotation_rads)
		$CollisionShape2D.set_rotation(rotation_rads)
		$LegsSprite.animation = "walk"
		$BodySprite.animation = "walk"
	else:
		$LegsSprite.animation = "stand"
		$BodySprite.animation = "stand"
	
	# TODO: create collision box for body
	var aim_direction = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	var aim_rads = atan2(aim_direction.y, aim_direction.x)
	
	if aim_direction.y != 0 or aim_direction.x != 0:
		$BodySprite.set_rotation(aim_rads)
	
	if Input.is_action_just_pressed("shoot"):
		shoot_bullet($BodySprite.rotation)
		
func shoot_bullet(rotation_rads):
	# find the weapon we are shooting
	# generate a new bullet in the right direction
	shoot.emit(PlayerBullet, rotation_rads, position)
	return
	


func _on_body_entered(body):
	if body.is_in_group("player_bullets"):
		pass
	elif body.is_in_group("enemies"):
		# TODO: calculate damage and send that in emit
		#hide() # Player disappears after being hit.
		hit.emit()
		# Must be deferred as we can't change physics properties on a physics callback.
		#$CollisionShape2D.set_deferred("disabled", true)
	else:
		pass
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
