extends CharacterBody2D
const SPEED=200.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 800
const STUN_TIME=0.5

var double_jump: bool = false
var stun_delay=0
@onready var animation =get_node("AnimationPlayer")
@onready var sprite =get_node("DudeSprite")
signal hit
signal slime(collider)
enum State {IDLE,RUN,JUMP,DOUBLE_JUMP,STUN}
var current_state: State = State.IDLE
func set_state(new_state: State):
	current_state = new_state
func _ready() ->void:
	set_state(State.IDLE)
func handle_idle(delta):
	animation.play("idle")
	var direction = Input.get_axis("left", "right") 
	if direction!=0: 
		velocity.x = direction * SPEED
		set_state(State.RUN)
	else:
		velocity.x=move_toward(velocity.x,0,SPEED/15)
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		double_jump=true
		set_state(State.JUMP)
		
func handle_run(delta):
	animation.play("run")
	var direction = Input.get_axis("left", "right") 
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		double_jump=true
		set_state(State.JUMP)
	if direction!=0: 
		velocity.x = direction * SPEED
	else:
		set_state(State.IDLE)
		return
func handle_double_jump(delta):
	animation.play("double_jump")
	var direction = Input.get_axis("left", "right") 
	velocity.x = lerp(velocity.x,direction*SPEED,0.2)
	if velocity.y>0:
		set_state(State.JUMP)
	
func update_flip():
	sprite.flip_h = velocity.x < 0
func handle_jump(delta):
	animation.play("jump")
	if Input.is_action_just_pressed("jump") and double_jump:
		velocity.y = JUMP_VELOCITY
		double_jump=false
		set_state(State.DOUBLE_JUMP)
	var direction = Input.get_axis("left", "right") 
	velocity.x = lerp(velocity.x,direction*SPEED,0.2)
func handle_collisions(delta):
	var platform = null
	var collision_count = get_slide_collision_count()
	for i in collision_count:
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		if "StaticBox" in collider.name:
			var force = 1
			if normal.y<0:
				force=0.5
			hit.emit()
			velocity=normal*SPEED*4*force
			set_state(State.DOUBLE_JUMP)
		if "slime" in collider.name and global_position.y+30 < collider.global_position.y:
			slime.emit(collider)
		if "Wall" in collider.name:
			if abs(normal.x)>0.8:
				velocity = normal*SPEED
				stun_delay=STUN_TIME
				set_state(State.STUN)
		if "Breach" in collider.name:
			platform = collider
	if Input.is_action_just_pressed("down") and platform !=null:
		var collision = platform.get_child(0)
		collision.disabled=true
		await get_tree().create_timer(0.1).timeout
		collision.disabled=false
func handle_stun(delta):
	if stun_delay <=0:
		set_state(State.IDLE)
	stun_delay-=delta
func _physics_process(delta:float)->void:
	match current_state:
		State.IDLE:
			handle_idle(delta)
		State.RUN:
			handle_run(delta)
		State.JUMP:
			handle_jump(delta)
		State.DOUBLE_JUMP:
			handle_double_jump(delta)
		State.STUN:
			handle_stun(delta)
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	update_flip()
	move_and_slide()
	handle_collisions(delta)
	if is_on_floor() and current_state in [State.JUMP,State.DOUBLE_JUMP]:
		if abs(velocity.x)>0:
			set_state(State.RUN)
		else:
			set_state(State.IDLE)



#func _physics_process(delta: float) -> void:
	#if not is_on_floor():
		#velocity.y += GRAVITY * delta
	#var direction = Input.get_axis("ui_left", "ui_right")  
	#velocity.x = direction * SPEED
	#if Input.is_action_just_pressed("ui_up") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
	#elif Input.is_action_just_pressed("ui_up") and not is_on_floor() and not is_double_jump:
		#velocity.y = JUMP_VELOCITY
		#is_double_jump = true
	#if direction != 0:
		#sprite.flip_h = direction < 0
	#if not is_on_floor():
		#animation.play("double_jump" if is_double_jump else "jump")
	#elif direction != 0:
		#animation.play("run")
		#is_double_jump = false
	#else:
		#animation.play("idle")
		#is_double_jump = false
	#move_and_slide()
