extends Node2D

var _timer = Timer.new()

func _ready():
	add_child(_timer)
	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_wait_time(global.badguy_spawn_timer)
	_timer.set_one_shot(false) # Make sure it loops
	_timer.start()
	

func _on_Timer_timeout():
	if global.player_alive == true:
		_timer.set_wait_time(global.badguy_spawn_timer)
		var which_enemy = randi()%21+1
		if (which_enemy >= 0 && which_enemy < 3) && can_bad_guy_spawn(1):
			global.set_enemy(1)
		elif (which_enemy >= 3 && which_enemy < 6) && can_bad_guy_spawn(2):
			global.set_enemy(2)
		elif (which_enemy >= 6 && which_enemy < 8) && can_bad_guy_spawn(3):
			global.set_enemy(3)
		elif (which_enemy >= 8 && which_enemy < 10) && can_bad_guy_spawn(4):
			global.set_enemy(4)
		elif (which_enemy >= 10 && which_enemy < 12) && can_bad_guy_spawn(5):
			global.set_enemy(5)
		elif (which_enemy == 12) && can_bad_guy_spawn(6):
			global.set_enemy(6)
		else:
			global.set_enemy(0)
		var bad_dude_resource = load("res://Scenes/baddude.tscn").instance()
		var which_spawn = randi()%5+1
		var randx = randi()%1024+1
		var randy = randi()%600+1
		var spawn_loc = Vector2(0,0)
		match which_spawn:
			1:
				spawn_loc = Vector2(randx,0)
			2:
				spawn_loc = Vector2(0,randy)
			3:
				spawn_loc = Vector2(1024,randy)
			4:
				spawn_loc = Vector2(randx,600)
		bad_dude_resource.position = spawn_loc
		get_tree().get_root().add_child(bad_dude_resource)
		get_tree().call_group("bad_dudes", "set_player", get_node("Player").get_child(0))
	else:
		_timer.stop()
		
func can_bad_guy_spawn(entid):
	for node in global.badguy_can_spawn:
		if(node == entid):
			return true
	return false