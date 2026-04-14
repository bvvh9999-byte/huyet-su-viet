extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const DASH_SPEED = 600.0

var is_dashing = false
var is_attacking = false
var facing_right = true

@onready var sprite = $Sprite2D
@onready var dash_timer = $DashTimer
@onready var sword_hitbox = $SwordHitbox
@onready var sword_visual = $SwordHitbox/ColorRect

func _ready():
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	sword_visual.visible = false
	sword_hitbox.monitoring = false

func _physics_process(delta):
	if is_dashing:
		move_and_slide()
		return

	# Trọng lực
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Đánh
	if Input.is_action_just_pressed("attack") and not is_attacking and is_on_floor():
		attack()
		return

	if is_attacking:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		return

	# Nhảy
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Lướt
	if Input.is_action_just_pressed("dash") and is_on_floor():
		start_dash()
		return

	# Di chuyển
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		if direction > 0:
			sprite.flip_h = false
			facing_right = true
			sword_hitbox.scale.x = 1
		elif direction < 0:
			sprite.flip_h = true
			facing_right = false
			sword_hitbox.scale.x = -1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# Kỹ năng chém (Gây sát thương cho quái)
func attack():
	is_attacking = true
	sword_hitbox.monitoring = true
	sword_visual.visible = true
	
	var bodies = sword_hitbox.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Enemy"):
			if body.has_method("take_damage"):
				body.take_damage(10) # Chém mất 10 máu

	await get_tree().create_timer(0.2).timeout
	
	sword_hitbox.monitoring = false
	sword_visual.visible = false
	is_attacking = false

func start_dash():
	is_dashing = true
	velocity.y = 0
	if facing_right:
		velocity.x = DASH_SPEED
	else:
		velocity.x = -DASH_SPEED
	dash_timer.start()

func _on_dash_timer_timeout():
	is_dashing = false
