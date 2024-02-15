extends "res://App/Scenes/Entities/Components/Weapons/persistent_stationary_weapon.gd"


func attack_units_in_my_zone():
	var present_enemies = get_local_enemies()
	if not present_enemies.is_empty():
		var first_available_fish = present_enemies[0]
		if first_available_fish.has_method("_on_hit"):
				first_available_fish._on_hit(attack_packet)
		if owner.has_method("_on_attacked"):
			owner._on_attacked()
		var fish_sprite = owner.find_child("FishSprite")
		if fish_sprite != null:
			fish_sprite.texture = first_available_fish.unit_info.icon
			fish_sprite.show()
