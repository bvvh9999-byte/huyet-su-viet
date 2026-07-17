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
@onready var sprite = $Sprite2D # AnimatedSprite2D
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
# TRÍ TUỆ NHÂN TẠO (AI) DI CHUYỂN
# ==========================================
func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if player != null and can_attack: 
		var direction = (player.global_position - global_position).normalized()
		velocity.x = direction.x * speed
		
		if direction.x > 0:
			sprite.flip_h = false
			attack_area.scale.x = 1
		elif direction.x < 0:
			sprite.flip_h = true
			attack_area.scale.x = -1
			
		if sprite != null and sprite.animation != "run":
			sprite.play("run")
			
		attempt_attack()
	else:
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

func _on_attack_timer_timeout(): 
	can_attack = true

func _on_detection_entered(body): 
	if body.name == "Player": player = body
		
func _on_detection_exited(body): 
	if body.name == "Player": player = null

# ==========================================
# CHỊU SÁT THƯƠNG VÀ CHẾT (ĐÃ FIX LỖI EXP)
# ==========================================
func take_damage(damage_amount):
	hp -= damage_amount 
	health_bar.value = hp 
	
	sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout 
	sprite.modulate = Color(1, 1, 1) 
	
	if hp <= 0:
		# 1. RỚT KINH NGHIỆM BẰNG TỌA ĐỘ TUYỆT ĐỐI (Chống trượt)
		var player_chinh = get_tree().current_scene.get_node_or_null("Player")
		if player_chinh != null:
			if player_chinh.has_method("gain_exp"):
				print("=> Quái chết! Đang bơm 50 EXP cho Player...")
				player_chinh.gain_exp(50)
		else:
			print("=> LỖI: Quái chết nhưng không tìm thấy 'Player' ngoài Map để cho EXP!")
				
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
			
		# 4. CHẠY ANIMATION CHẾT VÀ BỐC HƠI
		if sprite != null: sprite.play("die")
		$CollisionShape2D.set_deferred("disabled", true)
		await get_tree().create_timer(1.0).timeout
		queue_free()
