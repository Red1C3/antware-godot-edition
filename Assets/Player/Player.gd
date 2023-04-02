extends KinematicBody

const SPEED=10

const ARMATURE_NAME="Armature"

const MOUSE_CLAMP_MIN=deg2rad(-60)
const MOUSE_CLAMP_MAX=deg2rad(60)

var mouse_sensetivity=0.1 #TODO make it an option

var anim_player:AnimationPlayer

var armature:Spatial

var collision_shape:CollisionShape

var gravity=ProjectSettings.get_setting("physics/3d/default_gravity")

var velocity=Vector3.ZERO

var armature_default_basis:Basis

var cam_rot_x=0
var cam_rot_y=0

func _ready():
	set_vars()
	anim_player.play("idle")
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	if not is_on_floor():
		velocity.y-=gravity
	else:
		
		var direction=Vector3.ZERO
		if Input.is_action_pressed("player_fwd"):
			direction+=armature.transform.basis.y
		if Input.is_action_pressed("player_bck"):
			direction-=armature.transform.basis.y
		if Input.is_action_pressed("player_left"):
			direction+=armature.transform.basis.x
		if Input.is_action_pressed("player_right"):
			direction-=armature.transform.basis.x
		direction=to_global(direction)-transform.origin
		velocity=direction.normalized()*SPEED
		
	velocity=move_and_slide(velocity,Vector3.UP)

func _input(event):
	if event.is_action("quit"):
		get_tree().quit(0) #TODO switch to return to menu/pause
		
	if event is InputEventMouseMotion:
		var mouse_pos=event.get_relative() * mouse_sensetivity
		cam_rot_x-=mouse_pos.x*mouse_sensetivity
		cam_rot_y+=mouse_pos.y*mouse_sensetivity
		cam_rot_y=clamp(cam_rot_y,MOUSE_CLAMP_MIN,MOUSE_CLAMP_MAX)
		armature.transform.basis=armature_default_basis
		armature.rotate_object_local(Vector3(0,0,-1), cam_rot_x)
		armature.rotate_object_local(Vector3(1, 0, 0), cam_rot_y)
		
func set_vars():
	for child in get_children():
		if child is AnimationPlayer:
			anim_player=child
		if child.name == ARMATURE_NAME:
			armature=child
			armature_default_basis=armature.transform.basis
		if child is CollisionShape:
			collision_shape=child


func deal_damage(damage):
	print(damage)
