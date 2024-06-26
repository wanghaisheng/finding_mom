extends Node

@export var mob_scene: PackedScene
var score

# Called when the node enters the scene tree for the first time.
func _ready():
	# send game music
	
	# start
	#new_game()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()
	
	$Player.hide()

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	
	
	get_tree().call_group("enemies", "queue_free")
	get_tree().call_group("bullets", "queue_free")
	
	$DeathSound.stop()
	$Music.play()
	
	# TODO: reset hearts
	$Player.show()
	$HUD.display_hearts()

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on Path2D.
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	# TODO: let the enemy move itself after letting it know of the player
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)


func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()



func _on_player_shoot(bullet, direction, location):
	# check to see if Player is alive ***CHANGE***
	if $Player.visible:
		var spawned_bullet = bullet.instantiate()
		spawned_bullet.position = location
		var velocity = Vector2(800.0, 0.0) # let the bullet set this
		spawned_bullet.linear_velocity = velocity.rotated(direction)
		add_child(spawned_bullet)


func _on_player_hit():
	if $Player.visible:
		do_damage()
	
func do_damage():
	$HUD.lose_heart()


func _on_hud_player_die():
	game_over()
