extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$Control/ScoreValue.set_text(str(global.session_score))
	getLeaderboardData()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func getLeaderboardData():
	var headers = ["User-Agent: LGJAM19Game"]
	$Control/HTTPRequestGET.request("https://autistic.games/leaderboard.php", headers, true)
	pass
	
	
func _on_Button_pressed():
	postScore()
	$Control/Submit.disabled = true


func _on_HTTPRequestGET_request_completed(result, response_code, headers, body):
	var json_resp = (body.get_string_from_utf8())
	var leaders = JSON.parse(json_resp)
	var top10text = ""
	for leader in leaders.get_result():
		top10text = top10text + leader['player_name'] + ": " + leader['score'] + "\n"
	$Control/Top10Value.set_text(top10text)
	
func postScore():
	var my_score = $Control/ScoreValue.text
	var my_name = $Control/PlayerName.text
	var my_key = 'redactedfam'
	
	var postfields = "key=" + my_key + "&name=" + my_name + "&score=" + my_score + "&session_time=" + str(global.session_time) + "&kills=" + str(global.player_kills) + "&deaths=" + str(global.player_deaths)
	var headers = ["Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(len(postfields))]
	$Control/HTTPRequestPOST.request("https://autistic.games/post.php", headers, true, HTTPClient.METHOD_POST, postfields)
	pass
	
func _on_HTTPRequestPOST_request_completed(result, response_code, headers, body):
	print("Score submitted")
	getLeaderboardData()
