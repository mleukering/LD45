extends Node

#environmental
var user_message_duration = 5000
var god_mode = false

#progression variables
var current_life_start = OS.get_ticks_msec()
var current_life_time = 0
var current_life_kills = 0
var current_life_projectiles_fired = 0
var current_life_hits = 0
var current_life_accuracy = float(0.0)
var session_kdratio = float(0.0)
var session_projectiles_fired = 0
var session_hits = 0
var session_accuracy = float(0.0)
var session_time_start = OS.get_ticks_msec()
var session_time = 0
var current_weapon = 0
var session_score = 0
var score_kill_value = 500
var score_death_penalty = 15000

#Modifiers
var player_damage_modifier = 1
var badguy_damage_modifier = 1
var player_speed_modifier = 1
var badguy_speed_modifier = .8
var player_health_modifier = 1
var badguy_health_modifier = 1

#Player Global Vars
var player_health = 100
var player_health_regen_rate = .02
var player_deaths = 0
var player_kills = 0
var player_move_speed = 250
var player_alive = true
var player_inventory = []
var player_projectile = "res://Textures/none.png"
var player_projectile_speed = 0
var player_projectile_damage = 0
var player_attack_speed = 0
var player_current_weapon_id = -1

#Badguy Global Vars
var badguy_can_spawn = [0]
var badguy_spawn_timer = 2.5
var badguy_move_speed = 150
var badguy_acceleration = .12
var badguy_attack_speed = 500
var badguy_health = 100
var badguy_damage = 45
var badguy_sprite = "res://Textures/baddude.png"
var badguy_rotates = true
var badguy_shoots = false
var badguy_projectile = "res://Textures/laser.png"
var badguy_projectile_speed = 400
var badguy_projectile_damage = 75
var badguy_projectile_sound = "red://Audio/none.wav"

#Projectile vars
var projectile_scene = "res://Scenes/projectile.tscn"
var projectile_lastfired = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_weapon(weapon):
	projectile_lastfired = 0
	var weapsettings = []
	match weapon:
		0:
			#crossbow
			weapsettings.append("res://Textures/Player.png") #player image for weapon
			weapsettings.append("res://Textures/arrow.png") #projectile image
			weapsettings.append(300) # projectile speed
			weapsettings.append(75) # projectile damage
			weapsettings.append(1000) #projectile attack speed
		1:
			#pistol
			weapsettings.append("res://Textures/Player.png") #player image for weapon
			weapsettings.append("res://Textures/bullet.png") #projectile image
			weapsettings.append(550) # projectile speed
			weapsettings.append(25) # projectile damage
			weapsettings.append(250) #projectile attack speed
		2:
			#rifle
			weapsettings.append("res://Textures/Player.png") #player image for weapon
			weapsettings.append("res://Textures/riflebullet.png") #projectile image
			weapsettings.append(700) # projectile speed
			weapsettings.append(40) # projectile damage
			weapsettings.append(150) #projectile attack speed
		3:
			#plasma cannon
			weapsettings.append("res://Textures/Player.png") #player image for weapon
			weapsettings.append("res://Textures/plasmaround.png") #projectile image
			weapsettings.append(175) # projectile speed
			weapsettings.append(200) # projectile damage
			weapsettings.append(400) #projectile attack speed
		4:
			#rocket
			weapsettings.append("res://Textures/Player.png") #player image for weapon
			weapsettings.append("res://Textures/rocket.png") #projectile image
			weapsettings.append(250) # projectile speed
			weapsettings.append(500) # projectile damage
			weapsettings.append(1000) #projectile attack speed
		5:
			#minigun
			weapsettings.append("res://Textures/Player.png") #player image for weapon
			weapsettings.append("res://Textures/minigunbullet.png") #projectile image
			weapsettings.append(800) # projectile speed
			weapsettings.append(20) # projectile damage
			weapsettings.append(40) #projectile attack speed
		6:
			#energy weapon
			weapsettings.append("res://Textures/Player.png") #player image for weapon
			weapsettings.append("res://Textures/energyweapon.png") #projectile image
			weapsettings.append(700) # projectile speed
			weapsettings.append(10000) # projectile damage
			weapsettings.append(2500) #projectile attack speed
	
	player_projectile = weapsettings[1]
	player_projectile_speed = weapsettings[2]
	player_projectile_damage = weapsettings[3]
	player_attack_speed = weapsettings[4]
	player_current_weapon_id = weapon
	set_inventory()
	return weapsettings[0]
	

func set_enemy(enemy):
	var settings = []
	match enemy:
		0:
			#default enemy
			settings.append(125) #movespeed
			settings.append(.08) #acceleration
			settings.append(500) #attack_speed
			settings.append(100) #health
			settings.append(30) #attack damage
			settings.append("res://Textures/baddude.png") #sprite
			settings.append(true) #enemy rotates
			settings.append(false) #enemy shoots
			settings.append("res://Textures/none.png") #badguy's projectile
			settings.append(0) # badguy projectile speed
			settings.append(0) # badguy projectile damage
			settings.append("res://Audio/none.wav") #badguy's projectile sound
		1:
			#red boi enemy
			settings.append(150) #movespeed
			settings.append(.2) #acceleration
			settings.append(300) #attack_speed
			settings.append(200) #health
			settings.append(50) #attack damage
			settings.append("res://Textures/baddudered.png") #sprite
			settings.append(true) #enemy rotates
			settings.append(false) #enemy shoots
			settings.append("res://Textures/none.png") #badguy's projectile
			settings.append(0) # badguy projectile speed
			settings.append(0) # badguy projectile damage
			settings.append("res://Audio/none.wav") #badguy's projectile sound
		2:
			#yellow boi enemy
			settings.append(200) #movespeed
			settings.append(.18) #acceleration
			settings.append(200) #attack_speed
			settings.append(50) #health
			settings.append(20) #attack damage
			settings.append("res://Textures/baddudeyellow.png") #sprite
			settings.append(true) #enemy rotates
			settings.append(false) #enemy shoots
			settings.append("res://Textures/none.png") #badguy's projectile
			settings.append(0) # badguy projectile speed
			settings.append(0) # badguy projectile damage
			settings.append("res://Audio/none.wav") #badguy's projectile sound
		3:
			#floaty turd enemy
			settings.append(50) #movespeed
			settings.append(.1) #acceleration
			settings.append(100) #attack_speed
			settings.append(500) #health
			settings.append(200) #attack damage
			settings.append("res://Textures/baddudeturds.png") #sprite
			settings.append(false) #enemy rotates
			settings.append(false) #enemy shoots
			settings.append("res://Textures/none.png") #badguy's projectile
			settings.append(0) # badguy projectile speed
			settings.append(0) # badguy projectile damage
			settings.append("res://Audio/none.wav") #badguy's projectile sound
		4:
			#jet enemy
			settings.append(60) #movespeed
			settings.append(0) #acceleration
			settings.append(1000) #attack_speed
			settings.append(200) #health
			settings.append(50) #attack damage
			settings.append("res://Textures/baddudejet.png") #sprite
			settings.append(true) #enemy rotates
			settings.append(true) #enemy shoots
			settings.append("res://Textures/laser.png") #badguy's projectile
			settings.append(400) # badguy projectile speed
			settings.append(75) # badguy projectile damage
			settings.append("res://Audio/laser.wav") #badguy's projectile sound
		5:
			#space gator dickhead enemy
			settings.append(150) #movespeed
			settings.append(0) #acceleration
			settings.append(200) #attack_speed
			settings.append(150) #health
			settings.append(99) #attack damage
			settings.append("res://Textures/evilspacegator.png") #sprite
			settings.append(true) #enemy rotates
			settings.append(false) #enemy shoots
			settings.append("res://Textures/laser.png") #badguy's projectile
			settings.append(0) # badguy projectile speed
			settings.append(0) # badguy projectile damage
			settings.append("res://Audio/none.wav") #badguy's projectile sound
		6:
			#robot enemy
			settings.append(20) #movespeed
			settings.append(0) #acceleration
			settings.append(5000) #attack_speed
			settings.append(1000) #health
			settings.append(10000) #attack damage
			settings.append("res://Textures/robot.png") #sprite
			settings.append(true) #enemy rotates
			settings.append(true) #enemy shoots
			settings.append("res://Textures/energyweapon.png") #badguy's projectile
			settings.append(700) # badguy projectile speed
			settings.append(250) # badguy projectile damage
			settings.append("res://Audio/robotgun.wav") #badguy's projectile sound
			
	
	badguy_move_speed = settings[0]
	badguy_acceleration = settings[1]
	badguy_attack_speed = settings[2]
	badguy_health = settings[3]
	badguy_damage = settings[4]
	badguy_sprite = settings[5]
	badguy_rotates = settings[6]
	badguy_shoots = settings[7]
	badguy_projectile = settings[8]
	badguy_projectile_speed = settings [9]
	badguy_projectile_damage = settings [10]
	badguy_projectile_sound = settings[11]

func checkInventory(wepid):	
	for node in player_inventory:
		if(node == wepid):
			return true
	return false
	
func set_inventory_image(node_name, image_to_set):
	var inv_item = get_tree().get_root().get_node("/root/World/HUD/Control/" + node_name)
	inv_item.texture = load("res://Textures/" + image_to_set + ".png")
	
func set_inventory():
	
	#Crossbow
	if checkInventory(0):
		if player_current_weapon_id == 0:
			set_inventory_image("Crossbow", "crossbowselected")
		else:
			set_inventory_image("Crossbow", "crossbow")
	else:
		set_inventory_image("Crossbow", "emptyitem")
		
	#Pistol	
	if checkInventory(1):
		if player_current_weapon_id == 1:
			set_inventory_image("Pistol", "pistolselected")
		else:
			set_inventory_image("Pistol", "pistol")
	else:
		set_inventory_image("Pistol", "emptyitem")
		
	#Rifle
	if checkInventory(2):
		if player_current_weapon_id == 2:
			set_inventory_image("Rifle", "rifleselected")
		else:
			set_inventory_image("Rifle", "rifle")
	else:
		set_inventory_image("Rifle", "emptyitem")
		
	#PlamaGun
	if checkInventory(3):
		if player_current_weapon_id == 3:
			set_inventory_image("PlasmaGun", "plasmacannonselected")
		else:
			set_inventory_image("PlasmaGun", "plasmacannon")
	else:
		set_inventory_image("PlasmaGun", "emptyitem")
	
	#Rocket
	if checkInventory(4):
		if player_current_weapon_id == 4:
			set_inventory_image("Rocket", "rocketlauncherselected")
		else:
			set_inventory_image("Rocket", "rocketlauncher")
	else:
		set_inventory_image("Rocket", "emptyitem")
		
	#Minigun
	if checkInventory(5):
		if player_current_weapon_id == 5:
			set_inventory_image("Minigun", "minigunselected")
		else:
			set_inventory_image("Minigun", "minigun")
	else:
		set_inventory_image("Minigun", "emptyitem")
	
	#RobotArm
	if checkInventory(6):
		if player_current_weapon_id == 6:
			set_inventory_image("RobotArm", "robotarmselected")
		else:
			set_inventory_image("RobotArm", "robotarm")
	else:
		set_inventory_image("RobotArm", "emptyitem")