extends KinematicBody

const SPEED=1

const ANT_SCOPE=deg2rad(60)

const PLAYER_NAME="Player"

var agent:NavigationAgent

var player:KinematicBody

var ray_cast:RayCast

var detection_area:Area

var is_chasing=false

func _ready():
	set_vars()
	
func _process(delta):
	if not is_chasing:
		if detection_area.overlaps_body(player) and cast_ray_to_player():
			is_chasing=true

func _physics_process(delta):
	if is_chasing:
		transform=transform.looking_at(player.global_translation,Vector3.UP)
		agent.set_target_location(player.global_translation)
		var position=to_global(Vector3.ZERO)
		var next=agent.get_next_location()
		var direction=-position+next
		move_and_slide(direction.normalized()*SPEED,Vector3.UP)

	
func set_vars():
	for child in get_children():
		if child is NavigationAgent:
			agent=child
		if child is Area:
			detection_area=child
	for child in detection_area.get_children():
		if child is RayCast:
			ray_cast=child
	player=get_node("/root/Root/Actors/Player")

func cast_ray_to_player():
	ray_cast.cast_to=ray_cast.\
					to_local(player.collision_shape.global_translation).\
					normalized()
	if Vector3.FORWARD.angle_to(ray_cast.cast_to)>ANT_SCOPE:
		return false
	ray_cast.force_raycast_update()
	var collider=ray_cast.get_collider()
	if collider != null and collider.name==PLAYER_NAME:
		return true

func _on_DetectionArea_body_entered(body):
	if body is KinematicBody:
		if body.name==PLAYER_NAME and cast_ray_to_player():
			is_chasing=true


func _on_DetectionArea_body_exited(body):
	if body is KinematicBody:
		if body.name==PLAYER_NAME:
			is_chasing=false
