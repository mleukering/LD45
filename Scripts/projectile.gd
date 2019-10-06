extends KinematicBody2D

var projectile_sprite
var projectile_speed
var projectile_damage

func setup(projectile_sprite_init, projectile_speed_init, projectile_damage_init):
	projectile_sprite = projectile_sprite_init
	projectile_speed = projectile_speed_init
	projectile_damage = projectile_damage_init

func _ready():
	var projectile_sprite_node = get_node("Sprite")
	projectile_sprite_node.texture = load(projectile_sprite)

func _physics_process(delta):
	
	var velocity = Vector2(projectile_speed, 0).rotated(global_rotation) * delta
	var collider = move_and_collide(velocity)
	
	if collider:
		var coll = collider.get_collider()
		if coll.name == "BadDude":
			coll.hurt_badguy(projectile_damage * global.player_damage_modifier)
			global.current_life_hits += 1
			global.session_hits += 1
			if projectile_damage < 5000:
				kill()
		if coll.name == "Player":
			if !global.god_mode:
				coll.hurt_player(projectile_damage * global.badguy_damage_modifier)
			kill()
		if coll.name == "Projectile":
			global.current_life_hits += 1
			global.session_hits += 1
			kill()
	
	if global_position.x < 0 || global_position.x > 1024 || global_position.y < 0 || global_position.y > 600:
		kill()
		
	
func kill():
	self.queue_free()