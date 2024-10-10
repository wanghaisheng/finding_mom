extends Node

@export var mob_scene: PackedScene
@export var enemies_on = true

var portal_scene = preload("res://portal.tscn")

var spawn_locations = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _on_pause_menu_resume():
	flip_pause_screen()

func flip_pause_screen():
	if !get_tree().paused:
		get_tree().paused = true
		$PauseMenu.show()
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
	
	#TODO: kick us back out to the main menu somehow

#this function is called every time the start button is pressed
func new_game():
	play_next_level()
	$Player.live_again()

func play_next_level():
	# get the current level and tell the TileMap what to display next
	var level = $HUD.get_level()
	match level:
		0:
			# set grass
			pass
		1:
			# set something
			pass
		2:
			# set something
			pass
	$Player.start($StartPosition.position)
	$StartTimer.start()

	kill_all_active_things()
	
	$DeathSound.stop()
	$Music.play()
	
	$Player.set_is_dead(false)

	#$HUD.reset_health() #TODO decide if we want to reset health or not (leaning towards no)
	$HUD.display_hearts()
	$HUD.display_bullets()
	
	# display the next level only after the start button is pressed
	$HUD.next_level()
	$HUD.display_level()

func _on_mob_timer_timeout():
	if enemies_on:
		# Create a new instance of the Mob scene.
		var mob = mob_scene.instantiate()

		# ----------------------------------------
		# TODO: change where they spawn in AND let the enemy move itself
		# Choose a random location on Path2D.
		var mob_spawn_location = $Player.position
		#mob_spawn_location.progress_ratio = randf()
		var rand_theta = randf() * 2 * PI
		var distance_away = Vector2(sin(rand_theta) * 1920, cos(rand_theta) * 1920)

		# Set the mob's position to a random location.
		mob.position = mob_spawn_location + distance_away
		# ------------------------------------------
		
		# let the mob know where the player is
		mob.set_player($Player)
		
		mob.shoot.connect(_on_mob_shoot)

		# Spawn the mob by adding it to the Main scene.
		add_child(mob)


func _on_start_timer_timeout():
	$MobTimer.start()

func _on_player_shoot(bullet, direction, location):
	# TODO: connect a audio sound either here or inside of the Bullet
	# check to see if Player is alive
	if $Player.get_is_dead and $HUD.shoot_bullet():
		#var spawned_bullet = bullet.instantiate()
		#order matters here
		bullet.set_direction(direction)
		#spawned_bullet.set_sprite_rotation(direction)
		bullet.set_is_player_bullet()
		bullet.position = location
		add_child(bullet)
		bullet.player_bullet_dequeue.connect(_on_player_bullet_dequeue)
		
func _on_player_music_note(note):
	add_child(note)

func _on_mob_shoot(bullet, direction, location):
	#var bullet = bullet.instantiate()
	#order matters here
	bullet.set_direction(direction)
	bullet.set_is_enemy_bullet()
	bullet.position = location
	add_child(bullet)

func _on_player_bullet_dequeue():
	$HUD.reclaim_bullet()

func _on_player_hit():
	do_damage()

func do_damage():
	$HUD.lose_heart()


func _on_hud_player_die():
	game_over()


func kill_all_active_things():
	get_tree().call_group("enemies", "queue_free")
	get_tree().call_group("bullets", "queue_free")

func _on_hud_level_complete():
	var portal = portal_scene.instantiate()
	# TODO: here project the portal to a valid location
	portal.position = $StartPosition.position
	add_child(portal)
	
	kill_all_active_things()
	$MobTimer.stop()
	
	#TODO: stop current music and play level complete sound

func _on_player_entered_portal():
	play_next_level()
	get_tree().call_group("portals", "queue_free")

func _on_pause_menu_return_menu():
	get_tree().paused = false
	var main_menu = preload("res://main_menu.tscn")
	get_tree().change_scene_to_packed(main_menu)

# just return back to main menu
func _on_hud_quit_game():
	_on_pause_menu_return_menu()
	
func frame_freeze(ts, d):
	Engine.time_scale = ts
	var timer = get_tree().create_timer(d * ts)
	await timer.timeout
	Engine.time_scale = 1.0


func _on_mob_spawn_location_entered():
	pass # Replace with function body.


func _on_mob_spawn_location_exited():
	pass # Replace with function body.
