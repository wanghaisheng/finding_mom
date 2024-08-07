extends RigidBody2D

signal shoot(bullet, direction, location)

var type = "bug"

var player

enum states {
	MOVE,
	#ROLL, maybe???
	DEAD,
}
var current_state = states.MOVE

var BugBullet = preload("res://enemy_bullet.tscn")

func _ready():
	var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	var i = randi() % mob_types.size()
	set_type(mob_types[i])
	$AnimatedSprite2D.play(type)
	#$DeadSprites.play(type)	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match type:
		"bug":
			move_bug()
		"spider":
			move_spider()
	pass
	
func move_bug():
	pass
	
func move_spider():
	if current_state != states.DEAD:
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
	
func set_player(p):
	player = p
	

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_body_entered(body):
	if body.is_in_group("player_bullets"):
		$AnimatedSprite2D.hide()
		$DeadSprites.show()
		$DeadSprites.play(type)	
		current_state = states.DEAD
		#remove from both layers of collision
		collision_layer = 0
		collision_mask = 0


func _on_bullet_timer_timeout():
	match type:
		"bug":
			if current_state != states.DEAD:
				shoot_bug_bullet()
		"spider":
			pass
			
func shoot_bug_bullet():
	#TODO BUG: projectile doesn't interact with anything
	shoot.emit(BugBullet, rotation, position)
	pass

# unused atm
func set_type(t):
	type = t



func _on_dead_sprites_animation_finished():
	queue_free()
