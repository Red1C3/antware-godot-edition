extends KinematicBody

const SPEED=1

var agent:NavigationAgent

var player:KinematicBody

func _ready():
	set_vars()
	
func _physics_process(delta):
	transform=transform.looking_at(player.global_translation,Vector3.UP)
	agent.set_target_location(player.global_translation)
	var position=to_global(Vector3.ZERO)
	var next=agent.get_next_location()
	var direction=-position+next
	move_and_slide(direction.normalized()*SPEED,Vector3.UP)

	
func set_vars():
	var children=get_children()
	for child in children:
		if child is NavigationAgent:
			agent=child
	player=get_node("/root/Root/Actors/Player")
