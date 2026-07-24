extends CharacterBody2D

# ==========================================
# THÔNG SỐ CƠ BẢN
# ==========================================
var hp = 30 
var speed = 100.0 
var player = null 
var can_attack = true 

# ==========================================
# KẾT NỐI VỚI CÁC NODE CON
# ==========================================
@onready var health_bar = $ProgressBar 
@onready var sprite = $Sprite2D # Chắc chắn ngoài Scene nó là AnimatedSprite2D nhé
@onready var detection_area = $DetectionArea
@onready var attack_area = $AttackArea
@onready var attack_timer = $AttackTimer

func _ready():
	health_bar.max_value = hp
	health_bar.value = hp
	add_to_group("Enemy")
	
	if sprite != null:
		sprite.play("idle")
	
	if not detection_area.body_entered.is_connected(_on_detection_entered):
		detection_area.body_entered.connect(_on_detection_entered)
		detection_area.body_exited.connect(_on_detection_exited)
		attack_timer.timeout.connect(_on_attack_timer_timeout)

# ==========================================
# TRÍ TUỆ NHÂN TẠO (AI) ĐÃ SỬA LỖI ĐỨNG IM
# ==========================================
func _physics_process(delta):
	# Nếu chết rồi thì khóa não, chỉ rơi tự do
	if hp <= 0:
		if not is_on_floor(): velocity += get_gravity() * delta
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if player != null and can_attack: 
		# Tính khoảng cách và hướng đi
		var khoang_cach = abs(player.global_position.x - global_position.x)
		var huong_x = sign(player.global_position.x - global_position.x)
		
		# Đổi hướng mặt và mồm
		if huong_x > 0:
			sprite.flip_h = false
			attack_area.scale.x = 1
		elif huong_x < 0:
			sprite.flip_h = true
			attack_area.scale.x = -1
			
		# 👉 NẾU PLAYER Ở XA: CHẠY TỚI!
		if khoang_cach > 40:
			velocity.x = huong_x * speed
			if sprite != null and sprite.animation != "run":
				sprite.play("run")
				
		# 👉 NẾU Ở GẦN: THẮNG GẤP VÀ ĐÁNH!
		else:
			velocity.x = 0
			attempt_attack()
			
	else:
		# Không thấy ai thì đứng im
		velocity.x = move_toward(velocity.x, 0, speed)
		if sprite != null and sprite.animation != "attack" and sprite.animation != "die":
			sprite.play("idle")

	move_and_slide()

# ==========================================
# TẤN CÔNG PLAYER
# ==========================================
func attempt_attack():
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.name == "Player" and body.has_method("take_damage"):
			can_attack = false 
			velocity.x = 0
			
			if sprite != null: sprite.play("attack")
			
			body.take_damage(10) 
			attack_timer.start() 
			
			# (Không cần đổi màu lúc đánh nữa vì đã có ảnh vung chùy)

func _on_attack_timer_timeout(): 
	can_attack = true

# ==========================================
# RADAR TÌM PLAYER
# ==========================================
func _on_detection_entered(body): 
	if body.name == "Player": player = body
		
func _on_detection_exited(body): 
	if body.name == "Player": player = null

# ==========================================
# CHỊU SÁT THƯƠNG VÀ CHẾT (ĐÃ FIX LỖI EXP)
# ==========================================
func take_damage(damage_amount):
	if hp <= 0: return 
	
	hp -= damage_amount 
	health_bar.value = hp 
	
	sprite.modulate = Color(1, 0, 0) 
	await get_tree().create_timer(0.1).timeout 
	sprite.modulate = Color(1, 1, 1) 
	
	if hp <= 0:
		# Tắt vật lý để Player đi xuyên qua xác
		remove_from_group("Enemy") 
		$CollisionShape2D.set_deferred("disabled", true) 
		
		can_attack = false
		player = null
		velocity.x = 0 
		
		# 1. RỚT EXP BẰNG ĐỊA CHỈ TRỰC TIẾP
		var player_chinh = get_tree().current_scene.get_node_or_null("Player")
		if player_chinh != null and player_chinh.has_method("gain_exp"):
			player_chinh.gain_exp(50)
				
		# 2. BÁO CÁO NHIỆM VỤ
		var nhiem_vu_dang_lam = ""
		if Global.danh_sach_nhiem_vu["main_01"]["trang_thai"] == 1: nhiem_vu_dang_lam = "main_01"
		elif Global.danh_sach_nhiem_vu["main_02"]["trang_thai"] == 1: nhiem_vu_dang_lam = "main_02"
		
		if nhiem_vu_dang_lam != "":
			var nv = Global.danh_sach_nhiem_vu[nhiem_vu_dang_lam]
			if nv["da_lam"] < nv["muc_tieu"]: nv["da_lam"] += 1 

		# 3. PHÁT TIẾNG CHẾT
		var file_am_thanh = preload("res://Assets/monster_die.mp3") 
		if file_am_thanh:
			var may_phat = AudioStreamPlayer.new()
			may_phat.stream = file_am_thanh
			may_phat.volume_db = 5.0 
			may_phat.process_mode = Node.PROCESS_MODE_ALWAYS 
			get_tree().current_scene.add_child(may_phat)
			may_phat.play()
			may_phat.finished.connect(may_phat.queue_free)
			
		# 4. CHẠY ANIMATION CHẾT RỒI XÓA XÁC
		if sprite != null: sprite.play("die")
		
		# Chờ 1s cho nó diễn cảnh gục ngã rồi xóa
		await get_tree().create_timer(1.0).timeout
		queue_free()
