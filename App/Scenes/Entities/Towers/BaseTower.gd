## Towers are mostly static. They have a turret which may or may not rotate.

class_name BaseTower extends Node2D

@export var projectile : PackedScene
enum turret_types { STATIC, ROTATING, AoE }
@export var turret_type = turret_types.STATIC

var active_target
var turret_rotation : float # radians from Vector2.RIGHT

var shots_per_magazine : int = 3
var shots_remaining : int = 3

var health_max : float = 100.0
var health : float = health_max

func _ready():
	if turret_type == turret_types.ROTATING:
		$ActivationTriggers/CircularShape.disabled = false
		$ActivationTriggers/LinearShape.disabled = true
	else:
		$ActivationTriggers/CircularShape.disabled = true
		$ActivationTriggers/LinearShape.disabled = false

	turret_rotation = PI # Vector2.LEFT

func _unhandled_input(_event):
	if Input.is_action_just_pressed("shoot_all_towers"):
		shoot()
	

func shoot():
	if shots_remaining > 0:
		shots_remaining -= 1
		var new_projectile = projectile.instantiate()
		# TODO: add a targeting lead based on the velocity of the target and projectile
		add_sibling(new_projectile)
		new_projectile.global_position = $MuzzleLocation.global_position
		if active_target != null and is_instance_valid(active_target):
			new_projectile.activate(global_position.direction_to(active_target.global_position))
		else:
			new_projectile.activate(Vector2.from_angle(turret_rotation))
		$RecoilTimer.start()
	else:
		$ReloadTimer.start()


func _on_activation_triggers_body_entered(body):
	if active_target == null or not is_instance_valid(active_target):
		if body.is_in_group("Units"):
			active_target = body
			shoot()


func _on_recoil_timer_timeout():
	shoot()


func _on_reload_timer_timeout():
	shots_remaining = shots_per_magazine
	if active_target != null:
		shoot()


func _on_activation_triggers_area_entered(area):
	if active_target == null or not is_instance_valid(active_target):
		if area.owner != null and area.owner.is_in_group("Units"):
			active_target = area
			shoot()


func _on_activation_triggers_area_exited(area):
	if area.owner != null and area.owner.is_in_group("Units"):
		if active_target == area.owner:
			choose_new_target()

func choose_new_target():
	var candidates = $ActivationTriggers.get_overlapping.areas()
	if candidates.size() > 0:
		active_target = get_closest(candidates)
	else:
		active_target = null
	
func get_closest(nodeList):
	var candidates = nodeList.duplicate()
	candidates.sort_custom(sort_ascending)
	return candidates[0]
	
func sort_ascending(a, b):
	var a_dist = global_position.distance_squared_to(a)
	var b_dist = global_position.distance_squared_to(b)
	return a_dist < b_dist

