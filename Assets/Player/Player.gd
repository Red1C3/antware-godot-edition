extends KinematicBody

const SPEED=10
const SPRINT_MULTIPLIER=2
const STARTING_HEALTH=100
const ARMATURE_NAME="Armature"
const ANT_CLASS_NAME="Ant"
const MOUSE_CLAMP_MIN=deg2rad(-60)
const MOUSE_CLAMP_MAX=deg2rad(60)
const BULLET_DAM=25
const MAG_SIZE=12
const MAG_COUNT=4 #TODO level dependant
const FOOTSTEPS_STREAM_NAME="FootstepsStream"
const FOOTSTEPS_THRESHOLD=0.001
const PITCH_MULTIPLIER=0.1
const HURT_PANEL_NAME="HurtPanel"
const YOU_WIN_PROMPT_NAME="YouWinPrompt"
const YOU_LOSE_PROMPT_NAME="YouLosePrompt"

var mouse_sensetivity=0.1 #TODO make it an option
var anim_player:AnimationPlayer
var armature:Spatial
var collision_shape:CollisionShape
var gravity=ProjectSettings.get_setting("physics/3d/default_gravity")
var velocity=Vector3.ZERO
var armature_default_basis:Basis
var cam_rot_x=0
var cam_rot_y=0
var health=STARTING_HEALTH
var ray:RayCast
var on_mag_bullets=MAG_SIZE
var off_mag_bullets=MAG_SIZE*(MAG_COUNT-1)
var footsteps_stream:AudioStreamPlayer3D
var hurt_stream:AudioStreamPlayer3D
var hurt_panel:Panel
var you_win_prompt:TextureRect
var you_lose_prompt:TextureRect
var has_lost=false

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
		if Input.is_action_pressed("run"):
			velocity=velocity*SPRINT_MULTIPLIER # TODO make footsteps faster
		
	velocity=move_and_slide(velocity,Vector3.UP)

func _process(delta):
	var pitch=velocity.length()*PITCH_MULTIPLIER
	if pitch>FOOTSTEPS_THRESHOLD:
		footsteps_stream.stream_paused=false
		footsteps_stream.pitch_scale=pitch
	else:
		footsteps_stream.stream_paused=true

func _input(event):
	if event.is_action("quit"):
		get_tree().quit(0) #TODO switch to return to menu/pause
		
	if event.is_action_pressed("shoot") and on_mag_bullets>0 \
										and not anim_player.is_playing():
		anim_player.play("shoot")
	
	if event.is_action_pressed("reload") and off_mag_bullets>0:
		anim_player.play("reload")
		
	if event is InputEventMouseMotion:
		var mouse_pos=event.get_relative() * mouse_sensetivity
		cam_rot_x-=mouse_pos.x*mouse_sensetivity
		cam_rot_y+=mouse_pos.y*mouse_sensetivity
		cam_rot_y=clamp(cam_rot_y,MOUSE_CLAMP_MIN,MOUSE_CLAMP_MAX)
		armature.transform.basis=armature_default_basis
		armature.rotate_object_local(Vector3(0,0,-1), cam_rot_x)
		armature.rotate_object_local(Vector3(1, 0, 0), cam_rot_y)
		
func set_vars():
	var control:Control
	for child in get_children():
		if child is AnimationPlayer:
			anim_player=child
		if child.name == ARMATURE_NAME:
			armature=child
			armature_default_basis=armature.transform.basis
		if child is CollisionShape:
			collision_shape=child
		if child is AudioStreamPlayer3D\
				 and child.name == FOOTSTEPS_STREAM_NAME:
			footsteps_stream=child
		if child is Control:
			control=child
			
	for child in armature.get_child(0).get_children():
		if child is BoneAttachment:
			ray=child.get_child(0)
	for child in armature.get_child(1).get_children():
		if child is AudioStreamPlayer3D:
			hurt_stream=child
	for child in control.get_children():
		if child is Panel and child.name==HURT_PANEL_NAME:
			hurt_panel=child
		if child is TextureRect and child.name==YOU_WIN_PROMPT_NAME:
			you_win_prompt=child
		if child is TextureRect and child.name == YOU_LOSE_PROMPT_NAME:
			you_lose_prompt=child
			


func deal_damage(damage):
	health-=damage
	hurt_stream.play()
	hurt_panel.visible=true
	if health<=0:
		game_over()

func game_over():
	has_lost=true
	
func shoot():
	on_mag_bullets-=1
	ray.force_raycast_update()
	var other=ray.get_collider()
	if other != null and \
				other.has_method("get_class") and \
	 			other.get_class() == ANT_CLASS_NAME:
		other.deal_damage(BULLET_DAM)

func reload():
	on_mag_bullets=MAG_SIZE
	off_mag_bullets-=MAG_SIZE


func _on_HurtStream_finished():
	hurt_panel.visible=false
