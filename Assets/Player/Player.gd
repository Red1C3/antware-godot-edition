extends KinematicBody

const SPEED=10

var anim_player:AnimationPlayer

var gravity=ProjectSettings.get_setting("physics/3d/default_gravity")

var velocity=Vector3.ZERO

func _ready():
	set_vars()
	anim_player.play("idle")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y-=gravity
	else:
		
		var direction=Vector3.ZERO
		if Input.is_action_pressed("player_fwd"):
			direction+=Vector3.FORWARD
		if Input.is_action_pressed("player_bck"):
			direction+=Vector3.BACK
		if Input.is_action_pressed("player_left"):
			direction+=Vector3.LEFT
		if Input.is_action_pressed("player_right"):
			direction+=Vector3.RIGHT
		direction=to_global(direction)-transform.origin
		direction*=-1
		velocity=direction.normalized()*SPEED
		
	velocity=move_and_slide(velocity,Vector3.UP)

func set_vars():
	var children=get_children()
	for child in children:
		if child is AnimationPlayer:
			anim_player=child
