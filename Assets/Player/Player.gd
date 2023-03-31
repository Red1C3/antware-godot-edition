extends KinematicBody

var anim_player:AnimationPlayer

var gravity=ProjectSettings.get_setting("physics/3d/default_gravity")

var velocity=Vector3.ZERO

func _ready():
	set_vars()
	anim_player.play("idle")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y-=gravity
	velocity=move_and_slide(velocity,Vector3.UP)

func set_vars():
	var children=get_children()
	for child in children:
		if child is AnimationPlayer:
			anim_player=child
