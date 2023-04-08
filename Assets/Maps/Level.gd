extends Spatial

const LEVEL_BOTTOM=-100

var player:KinematicBody
var ants:Spatial

func _ready():
	player=get_node("Actors/Player")
	ants=get_node("Actors/Ants")
	
func _process(_delta):
	if ants.get_child_count() ==0 :
		player.you_win_prompt.visible=true
		get_tree().paused=true
	if player.has_lost:
		player.you_lose_prompt.visible=true
		get_tree().paused=true
	if player.to_global(Vector3.ZERO).y<LEVEL_BOTTOM:
		player.you_lose_prompt.visible=true
		get_tree().paused=true
