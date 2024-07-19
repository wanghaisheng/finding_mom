extends Node

@export var mob_scene: PackedScene

var current_background

var grass_path = "res://Assets/Backgrounds/grass.png"
var lava_path = "res://Assets/Backgrounds/lava.png"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_pause_menu_resume():
	flip_pause_screen()

func flip_pause_screen():
	if !get_tree().paused:
		get_tree().paused = true
		$PauseMenu.show()
		pass
	elif get_tree().paused:
		get_tree().paused = false
		$PauseMenu.hide()

func game_over():
	$HUD.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()
	
	$HUD.hide_level()
	
	$Player.set_is_dead(true)
	
	#TODO: kick us back out to the main menu

#this function is called every time the start button is pressed
func new_game():
	play_next_level()
	$Player.live_again()

func play_next_level():
	$Player.start($StartPosition.position)
	$StartTimer.start()
	
	#$HUD.show_message("Get Ready")

	kill_all_active_things()
	
	$DeathSound.stop()
	$Music.play()
	
	# TODO: reset hearts
	$Player.set_is_dead(false)
	$HUD.display_hearts()
	$HUD.display_bullets()
	
	# display the next level only after the start button is pressed
	$HUD.next_level()
	$HUD.display_level()

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()


	# ----------------------------------------
	# TODO: change where they spawn in AND let the enemy move itself
	# TODO: change the parent of the enemies so they are always displayed on the same level
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
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	# ------------------------------------------
	
	# let the mob know where the player is
	mob.set_player($Player)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)


func _on_start_timer_timeout():
	$MobTimer.start()

func _on_player_shoot(bullet, direction, location):
	# TODO: connect a audio sound either here or inside of the Bullet
	# check to see if Player is alive TODO: CHANGE HOW THIS IS CHECKING
	if $Player.get_is_dead and $HUD.shoot_bullet():
		var spawned_bullet = bullet.instantiate()
		spawned_bullet.position = location
		var velocity = Vector2(1500.0, 0.0) # TODO: let the bullet set this
		spawned_bullet.linear_velocity = velocity.rotated(direction)
		spawned_bullet.set_sprite_rotation(direction)
		add_child(spawned_bullet)
		spawned_bullet.bullet_dequeue.connect(_on_bullet_dequeue)
		
func _on_bullet_dequeue():
	$HUD.reclaim_bullet()
		


func _on_player_hit():
	do_damage()

func do_damage():
	$HUD.lose_heart()


func _on_hud_player_die():
	game_over()


func kill_all_active_things():
	get_tree().call_group("enemies", "queue_free")
	#get_tree().call_group("bullets", "queue_free")

func _on_hud_level_complete():
	$Portal.show()
	
	kill_all_active_things()
	$MobTimer.stop()
	#$HUD.show_start()
	
	#TODO: stop current music and play level complete sound
	
	# TODO: get the current level and see which background and enemies to display next
	var level = $HUD.get_level()
	var area = level / 1 # TODO: set to 10
	match area:
		0:
			# set grass
			current_background = ResourceLoader.load(grass_path)
			pass
		1:
			# set something
			current_background = ResourceLoader.load(lava_path)
			pass
		2:
			# set something
			pass
		3:
			#set lava
			pass
		4:
			# set space
			pass
		5:
			#show ending
			pass
	$Background.texture = current_background

	# TODO: create the portal and entering portal logic
func _on_player_entered_portal():
	print("start next")
	play_next_level()
	$Portal.hide()

func _on_pause_menu_return_menu():
	get_tree().change_scene_to_file("res://main_menu.tscn")
