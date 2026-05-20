extends CharacterBody2D

@export var SPEED = 200.0
@export var JUMP_VELOCITY = -800.0
@export var DASH_SPEED = 600.0

var is_dashing = false
var is_attacking = false
var facing_right = true

@onready var sprite = $Sprite2D
@onready var dash_timer = $DashTimer
@onready var sword_hitbox = $SwordHitbox
@onready var sword_visual = $SwordHitbox/ColorRect
@onready var health_bar = $CanvasLayer/HealthBar
@onready var exp_bar = $CanvasLayer/ExpBar

var game_over_scene = preload("res://UI/game_over_screen.tscn")

func _ready():
	# 1. TỰ ĐỘNG NỐI DÂY ĐIỆN CHO THANH KIẾM (Đảm bảo 100% không trượt)
	sword_hitbox.body_entered.connect(_on_sword_hit_something)
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	
	# 2. Giấu kiếm khi mới vào game
	sword_visual.visible = false
	sword_hitbox.monitoring = false
	
	health_bar.max_value = Global.max_hp
	health_bar.value = Global.player_hp
	
	exp_bar.max_value = Global.exp_to_next_level
	exp_bar.value = Global.player_exp

func _physics_process(delta):
	if is_dashing:
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	# Bấm chém
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

# ==========================================
# CƠ CHẾ CHÉM ĐÍCH THỰC (KHÔNG THỂ TRƯỢT)
# ==========================================
func attack():
	is_attacking = true
	# Bật thanh kiếm lên (Lúc này hàm _on_sword_hit_something sẽ tự động kích hoạt nếu chạm)
	sword_visual.visible = true
	sword_hitbox.monitoring = true 
	
	# Đợi 0.2s cho xong nhát chém
	await get_tree().create_timer(0.2).timeout
	
	# Tắt kiếm
	sword_hitbox.monitoring = false
	sword_visual.visible = false
	is_attacking = false

# HÀM TỰ ĐỘNG KÍCH HOẠT KHI KIẾM QUẸT TRÚNG AI ĐÓ
func _on_sword_hit_something(body):
	# Nếu vật bị quẹt có hàm trừ máu VÀ không phải là chính mình
	if body.has_method("take_damage") and body != self:
		body.take_damage(10)
		print("=> ĐÃ CHÉM TRÚNG: ", body.name)

# ==========================================
# CÁC KỸ NĂNG KHÁC
# ==========================================
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

func take_damage(amount):
	Global.player_hp -= amount
	health_bar.value = Global.player_hp
	
	sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1)
	
	if Global.player_hp <= 0:
		if game_over_scene:
			var game_over = game_over_scene.instantiate()
			get_tree().root.add_child(game_over)
			get_tree().paused = true

# --- HÀM NHẬN KINH NGHIỆM KHI GIẾT QUÁI ---
func gain_exp(amount):
	Global.player_exp += amount
	
	# Nếu lượng EXP vượt mốc yêu cầu -> LÊN CẤP!
	if Global.player_exp >= Global.exp_to_next_level:
		Global.player_level += 1
		Global.player_exp -= Global.exp_to_next_level # Giữ lại phần dư
		Global.exp_to_next_level += 50 # Cấp sau cần nhiều EXP hơn (150, 200...)
		
		# Hiệu ứng lên cấp: Hồi đầy máu và nháy chớp màu Vàng
		Global.player_hp = Global.max_hp
		health_bar.value = Global.player_hp
		sprite.modulate = Color(1, 1, 0) # Nháy vàng
		print("=> LEVEL UP! ĐÃ ĐẠT CẤP ĐỘ: ", Global.player_level)
		await get_tree().create_timer(0.3).timeout
		sprite.modulate = Color(1, 1, 1)

	# Cập nhật lại thanh EXP hiển thị trên màn hình
	exp_bar.max_value = Global.exp_to_next_level
	exp_bar.value = Global.player_exp
