extends CharacterBody2D

signal shoot(bullet, direction, location)

var type = "bug"

var mob_types = [
	"bug",
	"soldier",
	"spider",
]

var player

enum states {
	MOVE,
	DEAD,
	SHOOT,
}

var current_state = states.MOVE

var ready_shoot = true

var Bullet = preload("res://bullet.tscn")

#TODO: finish using this
const level_one_chances = [
	0,
	40,
	60
]

func start_animations(v: Vector2):
	if current_state == states.MOVE:
		if v.length() > 0:
			$AnimatedSprite2D.play()
		else:
			$AnimatedSprite2D.stop()

func _ready():
	# TODO: maybe create a more sophisticated way of determining the new mob? Like only create some enemies in the first level.
	var i = randi() % mob_types.size()
	set_type(mob_types[i])
	$AnimatedSprite2D.play(type)
	if type == "bug":
		# Add some randomness to the direction.
		velocity = Vector2(randi_range(-360, 360), randi_range(-360, 360)).normalized() * 360
		rotation = atan2(velocity.normalized().y, velocity.normalized().x)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	match type:
		"bug":
			move_bug()
		"spider":
			move_spider()
		"soldier":
			move_soldier()
	pass
	
func move_bug():
	if ready_shoot == true:
		shoot_bullet()
		
	# the velocity was set at _ready, we can just call move_and_slide()
	move_and_slide()
	
func move_spider():
	if current_state != states.DEAD:
		look_at(player.position)
		var motion = player.position
		motion = motion - position
		motion = motion.normalized()
		motion = motion * 400
		velocity = motion
		move_and_slide()
		
		
func move_soldier():
	var v = player.position - position
	var distance_to_player = sqrt((v.x * v.x) + (v.y * v.y))
	if current_state == states.SHOOT:
		look_at(player.position)
		if ready_shoot:
			change_living_texture("soldier_attack", false)
		elif distance_to_player > 600 and $AnimatedSprite2D.animation != "soldier_attack" and $AnimatedSprite2D.animation != "soldier_attack_end": # if we aren't shooting and the player is far away, switch back to MOVE
			current_state = states.MOVE
	elif current_state == states.DEAD:
		velocity = Vector2(0, 0)
	elif current_state == states.MOVE:
		look_at(player.position)
		if distance_to_player > 600:
			var motion = player.position
			motion = motion - position
			motion = motion.normalized()
			motion = motion * 350
			velocity = motion
		else:
			velocity = Vector2.ZERO
			if ready_shoot:
				current_state = states.SHOOT
				change_living_texture("soldier_attack", false)
	start_animations(velocity)
	move_and_slide()

func set_player(p):
	player = p

func _on_bullet_timer_timeout():
	if current_state != states.DEAD:
		match type:
			"bug":
				ready_shoot = true
			"spider":
				pass
			"soldier":
				# mark that the soldier can shoot again, and let the _process function do that
				ready_shoot = true
			
func shoot_bullet():
	var b = Bullet.instantiate()
	var bt
	match type:
		"bug":
			bt = b.bullet_types.PURPLE_BALL
		"spider":
			bt = b.bullet_types.PURPLE_BALL
		"soldier":
			bt = b.bullet_types.SOLDIER_BULLET
		_:
			bt = b.bullet_types.PURPLE_BALL
	b.set_bullet(bt)
	shoot.emit(b, rotation, position)
	ready_shoot = false

func set_type(t):
	type = t

func _on_dead_sprites_animation_finished():
	queue_free()

func _on_animated_sprite_2d_animation_looped():
	if $AnimatedSprite2D.animation == "soldier_attack":
		change_living_texture("soldier_attack_end", false)
		shoot_bullet()
	elif $AnimatedSprite2D.animation == "soldier_attack_end":
		change_living_texture("soldier", true)
		current_state = states.MOVE
		
func change_living_texture(animation, repeat):
	$AnimatedSprite2D.play(animation)
	$AnimatedSprite2D.texture_repeat = repeat

func _on_area_2d_body_entered(body):
	if body.is_in_group("player_bullets"):
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.hide()
		$DeadSprites.look_at(player.position)
		$DeadSprites.show()
		$DeadSprites.play(type)
		current_state = states.DEAD
		# remove from both layers of collision
		collision_layer = 0
		collision_mask = 0
		$Area2D.collision_layer = 0
		$Area2D.collision_mask = 0
		# used to remove the bullet
		body.collide_with_target()
