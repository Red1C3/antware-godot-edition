class_name Ant

extends KinematicBody
enum State{idle,chase,attack}

const SPEED=1
const ANT_SCOPE=deg2rad(60)
const CHASE_DAM=10
const ATTACK_DAM=40
const PLAYER_NAME="Player"
const ARMATURE_NAME="Armature"
const BITE_ATTACHMENT_NAME="BiteAttachment"
const ANIM_PLAYER_IDLE_SPEED=1
const ANIM_PLAYER_ATK_SPEED=1
const ANIM_PLAYER_WALK_SPEED_FACTOR=1
const TARGET_DIS=4.7
const CLASS_NAME="Ant"

var agent:NavigationAgent
var player:KinematicBody
var ray_cast:RayCast
var anim_player:AnimationPlayer
var detection_area:Area
var damage_area:Area
var state setget set_state
var health=100

func _ready():
	set_vars()
	anim_player.play("idle")
	self.state=State.idle
	
func _process(delta):
	if self.state==State.idle:
		if detection_area.overlaps_body(player) and cast_ray_to_player():
			self.state=State.chase
	if to_global(Vector3.ZERO).distance_to(player.global_translation)<=TARGET_DIS:
		self.state=State.attack

func _physics_process(delta):
	if self.state==State.chase:
		transform=transform.looking_at(player.global_translation,Vector3.UP)
		agent.set_target_location(player.global_translation)
		var position=to_global(Vector3.ZERO)
		var next=agent.get_next_location()
		var direction=-position+next
		var velocity=move_and_slide(direction.normalized()*SPEED,Vector3.UP)
		anim_player.playback_speed=velocity.length()*\
									ANIM_PLAYER_WALK_SPEED_FACTOR


func damage_player():
	if damage_area.overlaps_body(player):
		match self.state:
			State.chase:
				player.deal_damage(CHASE_DAM)
			State.attack:
				player.deal_damage(ATTACK_DAM)
	
func set_vars():
	var armature
	for child in get_children():
		if child is NavigationAgent:
			agent=child
		if child is Area:
			detection_area=child
		if child is AnimationPlayer:
			anim_player=child
		if child.name == ARMATURE_NAME:
			armature=child
	for child in detection_area.get_children():
		if child is RayCast:
			ray_cast=child
	for child in armature.get_child(0).get_children():
		if child.name == BITE_ATTACHMENT_NAME:
			damage_area=child.get_child(0)
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
		State.attack:
			anim_player.playback_speed=ANIM_PLAYER_ATK_SPEED
			anim_player.play("attack")
	state=new_state

func get_class():
	return CLASS_NAME
	
func deal_damage(amount):
	health-=amount
	if health<=0:
		kill()
		
func kill():
	pass #TODO
