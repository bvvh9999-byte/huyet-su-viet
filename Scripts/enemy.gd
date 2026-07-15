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
@onready var sprite = $Sprite2D # Giờ đây nó là AnimatedSprite2D
@onready var detection_area = $DetectionArea
@onready var attack_area = $AttackArea
@onready var attack_timer = $AttackTimer

func _ready():
	health_bar.max_value = hp
	health_bar.value = hp
	add_to_group("Enemy")
	
	# Ép quái vật đứng thở lúc mới sinh ra
	if sprite != null:
		sprite.play("idle")
	
	# Cắm dây điện tự động cho Radar và Đồng hồ
	if not detection_area.body_entered.is_connected(_on_detection_entered):
		detection_area.body_entered.connect(_on_detection_entered)
		detection_area.body_exited.connect(_on_detection_exited)
		attack_timer.timeout.connect(_on_attack_timer_timeout)

# ==========================================
# TRÍ TUỆ NHÂN TẠO (AI) DI CHUYỂN
# ==========================================
func _physics_process(delta):
	# 1. Trọng lực
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# 2. DI CHUYỂN
	if player != null: 
		var direction = (player.global_position - global_position).normalized()
		
		# 👉 IN RA ĐỂ XEM NÓ CÓ ĐANG BỊ KẸT TRẠNG THÁI KHÔNG
		print(">> THẤY PLAYER! Hướng X: ", direction.x, " | Có thể tấn công (can_attack): ", can_attack)
		
		if not can_attack: 
			velocity.x = move_toward(velocity.x, 0, speed)
		else:
			velocity.x = direction.x * speed
			print("=> Tốc độ X của quái đang là: ", velocity.x) # In ra xem có bị bằng 0 không!
			
			if sprite != null and sprite.animation != "run":
				sprite.play("run")
		
		# Lật mặt
		if direction.x > 0:
			sprite.flip_h = false
			attack_area.scale.x = 1
		elif direction.x < 0:
			sprite.flip_h = true
			attack_area.scale.x = -1
			
		if can_attack: attempt_attack()
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

# ==========================================
# CƠ CHẾ VUNG CHÙY (TẤN CÔNG)
# ==========================================
func attempt_attack():
	# Kiểm tra xem cái mồm (AttackArea) có chạm trúng Player chưa
	var bodies = attack_area.get_overlapping_bodies()
	
	for body in bodies:
		if body.name == "Player" and body.has_method("take_damage"):
			# 1. KHÓA CHÂN: Đứng im lại để vung chùy
			can_attack = false 
			velocity.x = 0
			
			# 2. BẬT ẢNH VUNG CHÙY
			if sprite != null:
				sprite.play("attack")
			
			# 3. TRỪ MÁU PLAYER
			body.take_damage(10) 
			
			# Nháy màu vàng cảnh báo
			sprite.modulate = Color(1, 1, 0)
			await get_tree().create_timer(0.2).timeout
			sprite.modulate = Color(1, 1, 1) # Về màu gốc (Không bị đen thui nữa)
			
			# 4. BẤM ĐỒNG HỒ NGHỈ NGƠI (Wait Time nên để 1.0 giây)
			attack_timer.start() 

func _on_attack_timer_timeout(): 
	can_attack = true

# ==========================================
# CẢM BIẾN (RADAR) TÌM PLAYER
# ==========================================
# ==========================================
# CẢM BIẾN (RADAR) TÌM PLAYER
# ==========================================
func _on_detection_entered(body): 
	print("\n>>> RADAR VỪA THẤY VẬT THỂ: ", body.name)
	if body.name == "Player": 
		player = body
		print("=> ĐÃ KHÓA MỤC TIÊU! BẮT ĐẦU CHẠY!")
		
func _on_detection_exited(body): 
	if body.name == "Player": 
		player = null
		print("=> MỤC TIÊU ĐÃ THOÁT KHỎI TẦM NHÌN!")

# ==========================================
# KHI BỊ CHÉM VÀ CHẾT
# ==========================================
func take_damage(damage_amount):
	hp -= damage_amount 
	health_bar.value = hp 
	
	sprite.modulate = Color(1, 0, 0) # Nháy đỏ
	await get_tree().create_timer(0.1).timeout 
	sprite.modulate = Color(1, 1, 1) # Về màu gốc
	
	if hp <= 0:
		# 1. RỚT EXP
		var danh_sach_player = get_tree().get_nodes_in_group("Player")
		if danh_sach_player.size() > 0:
			var player_dang_choi = danh_sach_player[0]
			if player_dang_choi.has_method("gain_exp"):
				player_dang_choi.gain_exp(50)
				
		# 2. BÁO CÁO NHIỆM VỤ
		var nhiem_vu_dang_lam = ""
		if Global.danh_sach_nhiem_vu["main_01"]["trang_thai"] == 1: nhiem_vu_dang_lam = "main_01"
		elif Global.danh_sach_nhiem_vu["main_02"]["trang_thai"] == 1: nhiem_vu_dang_lam = "main_02"
		
		if nhiem_vu_dang_lam != "":
			var nv = Global.danh_sach_nhiem_vu[nhiem_vu_dang_lam]
			if nv["da_lam"] < nv["muc_tieu"]:
				nv["da_lam"] += 1 

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
			
		queue_free()
