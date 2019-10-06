extends Node2D

onready var message_label = get_node("Control/PlayerMessage")

var message_post_time = OS.get_ticks_msec()
var message_active = true

#func _ready():
	#pass

func _process(delta):
	var healthvalue = get_node("Control/HealthValue")
	var killsvalue = get_node("Control/KillsValue")
	var deathsvalue = get_node("Control/DeathsValue")
	var accuracyvalue = get_node("Control/AccuracyValue")
	var scorevalue = get_node("Control/ScoreValue")
	healthvalue.text = " " + str(int(round(global.player_health)))
	killsvalue.text = " " + str(global.player_kills)
	deathsvalue.text = " " + str(global.player_deaths)
	accuracyvalue.text = " " + str(stepify(global.current_life_accuracy, .01))
	scorevalue.text = " " + str(global.session_score)

	if message_active == true && OS.get_ticks_msec() > (int(message_post_time) + int(global.user_message_duration)):
		message_active = false
		message_label.text = ("")
	
func set_player_message(msg):
	message_post_time = OS.get_ticks_msec()
	message_active = true
	message_label.text = (msg)
