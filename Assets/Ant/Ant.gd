extends KinematicBody
enum State{idle,chase}

const SPEED=1
const ANT_SCOPE=deg2rad(60)
const PLAYER_NAME="Player"
const ANIM_PLAYER_IDLE_SPEED=1
const ANIM_PLAYER_WALK_SPEED_FACTOR=1

var agent:NavigationAgent
var player:KinematicBody
var ray_cast:RayCast
var anim_player:AnimationPlayer
var detection_area:Area
var state setget set_state

func _ready():
	set_vars()
	anim_player.play("idle")
	self.state=State.idle
	
func _process(delta):
	if self.state==State.idle:
		if detection_area.overlaps_body(player) and cast_ray_to_player():
			self.state=State.chase

func _physics_process(delta):
	if self.state==State.chase:
		transform=transform.looking_at(player.global_translation,Vector3.UP)
		agent.set_target_location(player.global_translation)
		var position=to_global(Vector3.ZERO)
		var next=agent.get_next_location()
		var direction=-position+next
		var velocity=move_and_slide(direction.normalized()*SPEED,Vector3.UP)
		anim_player.playback_speed=velocity.length()*ANIM_PLAYER_WALK_SPEED_FACTOR


func damage_player():
	pass
	
func set_vars():
	for child in get_children():
		if child is NavigationAgent:
			agent=child
		if child is Area:
			detection_area=child
		if child is AnimationPlayer:
			anim_player=child
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
			self.state=State.chase


func _on_DetectionArea_body_exited(body):
	if body is KinematicBody:
		if body.name==PLAYER_NAME:
			self.state=State.idle

func set_state(new_state):
	match new_state:
		State.idle:
			anim_player.playback_speed=ANIM_PLAYER_IDLE_SPEED
			anim_player.play("idle")
		State.chase:
			anim_player.play("walk")
	state=new_state
