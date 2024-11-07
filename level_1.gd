extends Node2D
@export var enemies_on = true

signal spawn_mob(m: Resource)
signal spawn_portal(m: Resource)

var mob_spawn_scene = preload("res://spawn_location.tscn")
var mob_scene = preload("res://mob.tscn")

var valid_spawn_locations = []

# Called when the node enters the scene tree for the first time.
func _ready():
	create_spawn_locations()
	
func start_spawning():
	$MobTimer.start()
	
func stop_spawning():
	$MobTimer.stop()
	
#TODO: this function will create a portal in a valid location and emit it up/leave it here
func end_level(player_location: Vector2):
	return

func create_spawn_locations():
	var start = $MobSpawnLocation.position
	var end = $MobSpawnLocation2.position
	var step = 128
	var current = start
	while current.x <= end.x:
		while current.y <= end.y:
			# here create a spawn location and at it to the list
			var location: Node2D = mob_spawn_scene.instantiate()
			location.position = current
			location.exited.connect(location_exited)
			location.entered.connect(location_entered)
			add_child(location)
			valid_spawn_locations.append(location)
			current.y += step
		current.x += step
		current.y = start.y
		
# both of these seem to get called on creation so we dont have to remove them from the valid list by hand
func location_exited(n: Node2D):
	valid_spawn_locations.append(n)
func location_entered(n: Node2D):
	valid_spawn_locations.erase(n)

func _on_mob_timer_timeout():
	if enemies_on:
		# Create a new instance of the Mob scene.
		var mob = mob_scene.instantiate()
		# select a random spawn location from the valid list
		var n: Node2D = valid_spawn_locations[randi_range(0, len(valid_spawn_locations))]
		mob.position = n.position
		spawn_mob.emit(mob)
