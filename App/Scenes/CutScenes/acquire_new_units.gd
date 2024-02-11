extends Node2D

enum States { INITIALIZING, READY }
var State = States.INITIALIZING

# Called when the node enters the scene tree for the first time.
func _ready():
	for unit_metadata in Globals.unit_metadata:
		var num_remaining = Globals.surviving_units[unit_metadata.name]
		while (num_remaining > 0):
			num_remaining -= 1
			spawn_unit(unit_metadata)
		Globals.surviving_units[unit_metadata.name] = 0
	State = States.READY

	
func spawn_unit(unit_metadata):
	var new_unit = load("res://App/Scenes/Entities/Units/Procreator.tscn").instantiate()
	var screen_size = get_viewport_rect().size
	new_unit.global_position = Vector2(randf_range(10, screen_size.x-10), randf_range(10, screen_size.y-10))
	new_unit.activate(unit_metadata)
	add_child(new_unit)

func _process(_delta):
	if State == States.READY:
		if Engine.get_process_frames() % 30 == 0:
			if get_remaining_pairs_count() == 0:
				Globals.load_next_level()

func get_remaining_pairs_count() -> int:
	var remaining_pairs = 0
	for unit_metadata in Globals.unit_metadata:
		var remaining_procreators = 0
		for procreator in get_tree().get_nodes_in_group("Procreators"):
			if procreator.can_procreate():
				remaining_procreators += 1
		remaining_pairs += floor( float(remaining_procreators) / 2.0 )
	return remaining_pairs
	