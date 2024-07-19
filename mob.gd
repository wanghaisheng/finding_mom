extends RigidBody2D

var type = 1

var player

func _ready():
	var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	var i = randi() % mob_types.size()
	$AnimatedSprite2D.play(mob_types[i])
	set_type(mob_types[i])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match type:
		0:
			move_bug()
		1:
			move_spider()
	pass
	
func move_bug():
	pass
	
func move_spider():
	var motion = player.position
	motion = motion - position
	motion = motion.normalized()
	motion = motion * 5
	move_and_collide(motion)
	look_at(player.position)
	#var v = Vector2.ZERO
	#v.x = 50
	#v.y = 50
	#add_constant_force(v)
	pass
	
func set_player(p):
	player = p
	

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_body_entered(body):
	if body.is_in_group("player_bullets"):
		#TODO: play death animation
		queue_free()


func _on_bullet_timer_timeout():
	# TODO: produce a bullets from enemies
	pass

# unused atm
func set_type(t):
	type = $AnimatedSprite2D.sprite_frames.get_animation_names().find(t)

