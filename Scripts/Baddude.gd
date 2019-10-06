extends KinematicBody2D

onready var audio_player = get_tree().get_root().get_node("/root/World/BadGuyAudio")
onready var weapon_audio_player = get_tree().get_root().get_node("/root/World/BadGuyWeaponsAudio")

var player = null
var badguy_move_speed = global.badguy_move_speed
var badguy_health = global.badguy_health * global.badguy_health_modifier
var badguy_attack_speed = global.badguy_attack_speed
var badguy_attack_dmg = global.badguy_damage
var badguy_acceleration = global.badguy_acceleration
var badguy_sprite = global.badguy_sprite
var badguy_rotates = global.badguy_rotates
var badguy_shoots = global.badguy_shoots
var badguy_projectile = global.badguy_projectile
var badguy_projectile_speed = global.badguy_projectile_speed
var badguy_projectile_damage = global.badguy_projectile_damage
var badguy_projectile_sound = global.badguy_projectile_sound

var last_hurt = OS.get_ticks_msec()

func _ready():
	add_to_group("bad_dudes")
	var badguy_sprite = get_node("Sprite")
	badguy_sprite.texture = load(global.badguy_sprite)
	
func _physics_process(delta):
	if player == null:
		return
	
	if global.player_alive == true:
		var vec_to_player = player.global_position - global_position
		vec_to_player = vec_to_player.normalized()
		if badguy_rotates:
			global_rotation = atan2(vec_to_player.y, vec_to_player.x)
		var collider = move_and_collide(vec_to_player * (badguy_move_speed * global.badguy_speed_modifier) * delta)
		badguy_move_speed += badguy_acceleration
		if collider:
			var coll = collider.get_collider()
			if coll.name == "Player" && OS.get_ticks_msec() >= last_hurt + badguy_attack_speed:
				if !global.god_mode:
					coll.hurt_player(badguy_attack_dmg * global.badguy_damage_modifier)
				last_hurt = OS.get_ticks_msec()
		if badguy_shoots == true:
			if OS.get_ticks_msec() > last_hurt + badguy_attack_speed:
				var projectile_resource = load(global.projectile_scene).instance()
				projectile_resource.get_node("Projectile").setup(badguy_projectile, badguy_projectile_speed, badguy_projectile_damage)
				projectile_resource.rotation = atan2(vec_to_player.y, vec_to_player.x)
				projectile_resource.position = global_position + vec_to_player*32
				get_tree().get_root().add_child(projectile_resource)
				var music = load(badguy_projectile_sound)
				weapon_audio_player.set_stream(music)
				weapon_audio_player.play()
				last_hurt = OS.get_ticks_msec()
	else:
		self.queue_free()
	
	
			
			
func hurt_badguy(dmg):
	badguy_health -= dmg
	if badguy_health <= 0:
		kill() 
			
func kill():
	var music = load("res://Audio/badguykill.wav")
	audio_player.set_stream(music)
	audio_player.play()
	global.current_life_kills += 1
	global.player_kills += 1
	queue_free()
	
func set_player(p):
	player = p
	