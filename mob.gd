extends RigidBody2D

signal shoot(bullet, direction, location, bullet_name)

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

enum bullets {
	PURPLE_BALL,
	SOLDIER_BULLET,
}

var current_state = states.MOVE

var ready_shoot = true

var Bullet = preload("res://enemy_bullet.tscn")

func _ready():
	var i = randi() % mob_types.size()
	set_type(mob_types[i])
	$AnimatedSprite2D.play(type)

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
		shoot_bullet(bullets.PURPLE_BALL)
	
func move_spider():
	if current_state != states.DEAD:
		static_move()
		look_at(player.position)
		#var v = Vector2.ZERO
		#v.x = 50
		#v.y = 50
		#add_constant_force(v)
		
func move_soldier():
	if current_state == states.SHOOT:
		look_at(player.position)
		pass
	elif current_state != states.DEAD:
		look_at(player.position)
		var v = player.position - position
		var distance_to_player = sqrt((v.x * v.x) + (v.y * v.y))
		if distance_to_player > 600:
			static_move()
		else:
			if ready_shoot == true:
				linear_velocity = Vector2.ZERO
				angular_velocity = 0.0
				current_state = states.SHOOT
				change_living_texture("soldier_attack", false)
				
	
#TODO: when we figure out how to move things using forces, change this
func static_move():
	var motion = player.position
	motion = motion - position
	motion = motion.normalized()
	motion = motion * 5
	move_and_collide(motion)
	
func set_player(p):
	player = p
	

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_body_entered(body):
	if body.is_in_group("player_bullets"):
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.hide()
		$DeadSprites.look_at(player.position)
		$DeadSprites.show()
		$DeadSprites.play(type)
		current_state = states.DEAD
		#remove from both layers of collision
		collision_layer = 0
		collision_mask = 0


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
			
func shoot_bullet(b: int):
	shoot.emit(Bullet, rotation, position, b)
	ready_shoot = false

func set_type(t):
	type = t

func _on_dead_sprites_animation_finished():
	queue_free()

func _on_animated_sprite_2d_animation_looped():
	if $AnimatedSprite2D.animation == "soldier_attack":
		change_living_texture("soldier_attack_end", false)
		shoot_bullet(bullets.SOLDIER_BULLET)
	elif $AnimatedSprite2D.animation == "soldier_attack_end":
		change_living_texture("soldier", true)
		current_state = states.MOVE
		
func change_living_texture(animation, repeat):
	$AnimatedSprite2D.play(animation)
	$AnimatedSprite2D.texture_repeat = repeat
