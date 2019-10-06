extends KinematicBody2D

onready var audio_player = get_tree().get_root().get_node("/root/World/WeaponAudio")
onready var bonus_audio_player = get_tree().get_root().get_node("/root/World/BonusAudio")

func _ready():
	yield(get_tree(), "idle_frame")
	get_tree().call_group("bad_dudes", "set_player", self)
	global.player_alive = true
	global.set_inventory()
	
func _physics_process(delta):
	
	var look_vector = get_global_mouse_position() - global_position
	var direction = atan2(look_vector.y, look_vector.x)
	var player_location = self.get_global_transform_with_canvas().get_origin()
	var move_vector = Vector2()
	
	#Movement controls
	if Input.is_action_pressed("move_up") && player_location.y > 40:
		move_vector.y -= 1
	if Input.is_action_pressed("move_down") && player_location.y < 568:
		move_vector.y += 1
	if Input.is_action_pressed("move_left") && player_location.x > 14:
		move_vector.x -= 1
	if Input.is_action_pressed("move_right") && player_location.x < 1010:
		move_vector.x += 1
		
	#Spawn speed controller
	#if Input.is_action_just_pressed("increase_spawn_speed"):
		#global.badguy_spawn_timer -= 0.1
		#var player_msg_box = get_tree().get_root().get_node("/root/World/HUD/Control/PlayerMessage")
		#player_msg_box.text = ("Spawn rate increased")
	#if Input.is_action_just_pressed("decrease_spawn_speed"):
		#global.badguy_spawn_timer += 1
		#var player_msg_box = get_tree().get_root().get_node("/root/World/HUD/Control/PlayerMessage")
		#player_msg_box.text = ("Spawn rate descreased")
		
	#Shooting control
	if Input.is_action_pressed("shoot") && global.player_projectile != "res://Textures/none.png":
		var projectile_resource = load(global.projectile_scene).instance()
		projectile_resource.get_node("Projectile").setup(global.player_projectile, global.player_projectile_speed, global.player_projectile_damage)
		projectile_resource.rotation = direction
		projectile_resource.position = player_location + look_vector.normalized()*32
		if OS.get_ticks_msec() >= global.projectile_lastfired + global.player_attack_speed:
			get_tree().get_root().add_child(projectile_resource)
			global.projectile_lastfired = OS.get_ticks_msec()
			global.current_life_projectiles_fired += 1
			global.session_projectiles_fired += 1
			play_weapon_sound(global.player_current_weapon_id)
			##get_tree().get_root().get_node("/root/World/Shoot").play()
			
	#Weapons Controls
	if Input.is_action_just_pressed("weapon1"):
		if checkInventory(0):
			set_player_sprite(global.set_weapon(0))
	if Input.is_action_just_pressed("weapon2"):
		if checkInventory(1):
			set_player_sprite(global.set_weapon(1))
	if Input.is_action_just_pressed("weapon3"):
		if checkInventory(2):
			set_player_sprite(global.set_weapon(2))
	if Input.is_action_just_pressed("weapon4"):
		if checkInventory(3):
			set_player_sprite(global.set_weapon(3))
	if Input.is_action_just_pressed("weapon5"):
		if checkInventory(4):
			set_player_sprite(global.set_weapon(4))
	if Input.is_action_just_pressed("weapon6"):
		if checkInventory(5):
			set_player_sprite(global.set_weapon(5))
	if Input.is_action_just_pressed("weapon7"):
		if checkInventory(6):
			set_player_sprite(global.set_weapon(6))

	#if Input.is_action_just_pressed("weapon8"):
	#	set_player_sprite(global.set_weapon(7))
	#if Input.is_action_just_pressed("weapon9"):
	#	set_player_sprite(global.set_weapon(8))
	#if Input.is_action_just_pressed("weapon10"):
	#	set_player_sprite(global.set_weapon(9))
	 

	#Movement action
	move_vector = move_vector.normalized()
	move_and_collide(move_vector * (global.player_move_speed * global.player_speed_modifier) * delta)
	global_rotation = direction
	
	progression()
	
	#health regen
	if global.player_health < 100:
		global.player_health += global.player_health_regen_rate
		
#Snowflake mouse wheel code
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_WHEEL_UP:
			for x in range(global.player_current_weapon_id + 1, 7):
				if checkInventory(x):
					set_player_sprite(global.set_weapon(x))
					break
					
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_WHEEL_DOWN:
			for x in range(global.player_current_weapon_id -1, -1,-1):
				if checkInventory(x):
					set_player_sprite(global.set_weapon(x))
					break

func checkInventory(wepid):	
	for node in global.player_inventory:
		if(node == wepid):
			return true
	return false

func can_bad_guy_spawn(entid):
	for node in global.badguy_can_spawn:
		if(node == entid):
			return true
	return false
	
func play_weapon_sound(weaponid):
	var weapon_audio_resource = "res://Audio/arrow.wav"
	match weaponid:
		0:
			weapon_audio_resource = "res://Audio/arrow.wav"
		1:
			weapon_audio_resource = "res://Audio/pistol.wav"
		2:
			weapon_audio_resource = "res://Audio/rifle.wav"
		3:
			weapon_audio_resource = "res://Audio/plasma.wav"
		4:
			weapon_audio_resource = "res://Audio/rocket.wav"
		5:
			weapon_audio_resource = "res://Audio/pistol.wav"
		6:
			weapon_audio_resource = "res://Audio/robotgun.wav"
	
	var music = load(weapon_audio_resource)
	audio_player.set_stream(music)
	audio_player.play()

func progression():
	
	var player_msg_box = get_tree().get_root().get_node("/root/World/HUD")
	
	#--------------------------------------------------------------------------------
	# Progression Calulations
	#--------------------------------------------------------------------------------
	
	global.current_life_time = OS.get_ticks_msec() - global.current_life_start
	global.session_time = OS.get_ticks_msec() - global.session_time_start
	if global.session_projectiles_fired != 0 && global.session_hits != 0:
		global.session_accuracy =  float(global.session_hits) / global.session_projectiles_fired
	if global.current_life_projectiles_fired != 0 && global.current_life_hits != 0:
		global.current_life_accuracy = float(global.current_life_hits) / global.current_life_projectiles_fired
	if global.player_kills != 0 && global.player_deaths != 0:
		global.session_kdratio = float(global.player_kills) / global.player_deaths
	else:
		global.session_kdratio = global.player_kills
	global.session_score = (global.player_kills * global.score_kill_value) - (global.player_deaths * global.score_death_penalty)
	
	
	#--------------------------------------------------------------------------------
	# Environment Controls
	#--------------------------------------------------------------------------------

	if global.player_kills > 35 && global.player_kills < 100:
		global.badguy_spawn_timer = 2.5 - (global.player_kills * .02)
		
	if global.player_kills >= 150 && global.player_kills < 200 && checkInventory(2):
		global.badguy_speed_modifier = 1.3
		global.badguy_spawn_timer = 1.75
		
	if global.player_kills > 300 && global.player_kills < 310:
		global.badguy_spawn_timer = 1.5
		global.badguy_speed_modifier = .7
		
	if global.player_kills > 400 && global.player_kills < 410:
		global.badguy_spawn_timer = 2.5
		global.badguy_speed_modifier = .9
		global.badguy_health_modifier = 2.5
		global.badguy_damage_modifier = 2
		
	if global.player_kills > 500 && global.player_kills < 1250:
		global.badguy_health_modifier = 1
		global.badguy_damage_modifier = 1
		if global.badguy_spawn_timer >= .25:
			global.badguy_speed_modifier = .85
		if global.badguy_spawn_timer > .8:
			global.badguy_spawn_timer = 1.8 - ((global.player_kills - 500) * .005)
		
	if global.player_kills > 500 && global.badguy_spawn_timer < .81:
		if global.badguy_speed_modifier < 1.2:
			global.badguy_speed_modifier = 1 + ((global.player_kills - 725) * .002)
		
	if global.player_kills > 1250:
		global.badguy_health_modifier = 2
		global.badguy_damage_modifier = 2
		
		
	#--------------------------------------------------------------------------------
	# Enemy Progression
	#--------------------------------------------------------------------------------
		
	if global.player_kills >= 50 && can_bad_guy_spawn(1) == false:
		global.badguy_can_spawn.append(1)
		
	if global.player_kills >= 100 && !can_bad_guy_spawn(2):
		global.badguy_can_spawn.append(2)
		global.badguy_spawn_timer = 2.0
	
	if global.player_kills >= 200 && !can_bad_guy_spawn(3):
		global.badguy_can_spawn.append(3)
		
	if global.player_kills >= 250 && !can_bad_guy_spawn(4):
		global.badguy_can_spawn.append(4)
		
	if global.player_kills >= 300 && !can_bad_guy_spawn(5):
		global.badguy_can_spawn.append(5)
		
	if global.player_kills >= 350 && !can_bad_guy_spawn(6):
		global.badguy_can_spawn.append(6)
		
	#--------------------------------------------------------------------------------
	# Weapon Achievements
	#--------------------------------------------------------------------------------
		
	if checkInventory(0) == false && global.current_life_time >= 27000:
		var crossbow_inv = get_tree().get_root().get_node("/root/World/HUD/Control/Crossbow")
		crossbow_inv.texture = load("res://Textures/crossbow.png")
		player_msg_box.set_player_message("Crossbow Earned")
		global.player_inventory.append(0)
		var music = load("res://Audio/newweapon.wav")
		bonus_audio_player.set_stream(music)
		bonus_audio_player.play()
		
	if checkInventory(1) == false && global.player_kills >= 50:
		var crossbow_inv = get_tree().get_root().get_node("/root/World/HUD/Control/Pistol")
		crossbow_inv.texture = load("res://Textures/pistol.png")
		player_msg_box.set_player_message("Pistol Earned")
		global.player_inventory.append(1)
		global.badguy_speed_modifier = 1
		var music = load("res://Audio/newweapon.wav")
		bonus_audio_player.set_stream(music)
		bonus_audio_player.play()
		
	if checkInventory(2) == false && global.current_life_kills >= 50 && global.player_kills > 100:
		var crossbow_inv = get_tree().get_root().get_node("/root/World/HUD/Control/Rifle")
		crossbow_inv.texture = load("res://Textures/rifle.png")
		player_msg_box.set_player_message("Rifle Earned")
		global.player_inventory.append(2)
		var music = load("res://Audio/newweapon.wav")
		bonus_audio_player.set_stream(music)
		bonus_audio_player.play()
		
	if global.current_life_time >= 180000 && !checkInventory(3):
		var crossbow_inv = get_tree().get_root().get_node("/root/World/HUD/Control/PlasmaGun")
		crossbow_inv.texture = load("res://Textures/plasmacannon.png")
		player_msg_box.set_player_message("Plasma Gun Earned")
		global.player_inventory.append(3)
		var music = load("res://Audio/newweapon.wav")
		bonus_audio_player.set_stream(music)
		bonus_audio_player.play()
		
	if global.current_life_time >= 300000 && !checkInventory(4):
		var crossbow_inv = get_tree().get_root().get_node("/root/World/HUD/Control/Rocket")
		crossbow_inv.texture = load("res://Textures/rocketlauncher.png")
		player_msg_box.set_player_message("Rocket Launcher Earned")
		global.player_inventory.append(4)
		var music = load("res://Audio/newweapon.wav")
		bonus_audio_player.set_stream(music)
		bonus_audio_player.play()
		
	if global.player_kills >= 500 && !checkInventory(5):
		var crossbow_inv = get_tree().get_root().get_node("/root/World/HUD/Control/Minigun")
		crossbow_inv.texture = load("res://Textures/minigun.png")
		player_msg_box.set_player_message("Minigun Earned")
		global.player_inventory.append(5)
		var music = load("res://Audio/newweapon.wav")
		bonus_audio_player.set_stream(music)
		bonus_audio_player.play()
		
	if global.current_life_accuracy > .75 && global.player_kills >= 300 && global.current_life_kills >= 50 && !checkInventory(6):
		var crossbow_inv = get_tree().get_root().get_node("/root/World/HUD/Control/RobotArm")
		crossbow_inv.texture = load("res://Textures/robotarm.png")
		player_msg_box.set_player_message("Robot Super Weapon Earned")
		global.player_inventory.append(6)
		var music = load("res://Audio/newweapon.wav")
		bonus_audio_player.set_stream(music)
		bonus_audio_player.play()
	
	
func hurt_player(dmg):
	get_tree().get_root().get_node("/root/World/Hurt").play()
	global.player_health -= dmg
	if global.player_health <= 0:
		kill()
		
func set_player_sprite(theint):
	var ply_sprite = get_node("Sprite")
	ply_sprite.texture = load(theint)

func kill():
	global.player_deaths += 1
	global.player_alive = false
	get_tree().change_scene("res://Scenes/dedded.tscn")