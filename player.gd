extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const DASH_SPEED = 600.0

var is_dashing = false
var is_attacking = false
var facing_right = true
var game_over_scene = preload("res://UI/game_over_screen.tscn")

@onready var sprite = $Sprite2D
@onready var dash_timer = $DashTimer
@onready var sword_hitbox = $SwordHitbox
@onready var sword_visual = $SwordHitbox/ColorRect
@onready var health_bar = $CanvasLayer/HealthBar

func _ready():
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	sword_visual.visible = false
	sword_hitbox.monitoring = false
	
	health_bar.max_value = Global.max_hp
	health_bar.value = Global.player_hp

func _physics_process(delta):
	if is_dashing:
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("attack") and not is_attacking and is_on_floor():
		attack()
		return

	if is_attacking:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		return

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("dash") and is_on_floor():
		start_dash()
		return

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

# --- HÀM CHÉM ---
func attack():
	is_attacking = true
	sword_hitbox.monitoring = true
	sword_visual.visible = true
	
	await get_tree().physics_frame
	
	var bodies = sword_hitbox.get_overlapping_bodies()
	print("\n--- BẮT ĐẦU VUNG KIẾM ---")
	print("Thanh kiếm chạm vào: ", bodies.size(), " vật thể")
	
	for body in bodies:
		print("1. Tên vật thể bị chạm: ", body.name)
		print("2. Các nhóm của nó là: ", body.get_groups())
		print("3. Nó có não (code) chứa hàm take_damage không?: ", body.has_method("take_damage"))
		
		if body.is_in_group("Enemy"):
			if body.has_method("take_damage"):
				body.take_damage(10)
				print("=> KẾT LUẬN: ĐÃ CHÉM TRÚNG VÀ TRỪ MÁU!")
			else:
				print("=> LỖI: Thuộc nhóm Enemy nhưng KHÔNG TÌM THẤY hàm trừ máu!")
		else:
			print("=> LỖI: Vật bị chạm KHÔNG CÓ nhãn Enemy!")

	await get_tree().create_timer(0.2).timeout
	sword_hitbox.monitoring = false
	sword_visual.visible = false
	is_attacking = false

# --- HÀM LƯỚT ---
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

# --- HÀM BỊ TRỪ MÁU CỦA PLAYER ---
func take_damage(amount):
	Global.player_hp -= amount
	health_bar.value = Global.player_hp
	
	sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1)
	
	# NẾU HẾT MÁU -> GAME OVER
	if Global.player_hp <= 0:
		# 1. Tạo ra màn hình Game Over
		var game_over = game_over_scene.instantiate()
		get_tree().root.add_child(game_over) # Gắn nó vào màn hình
		
		# 2. Dừng đọng thời gian toàn thế giới (Quái vật đứng im)
		get_tree().paused = true
