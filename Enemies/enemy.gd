extends CharacterBody2D

var hp = 30 
var speed = 100.0 
var player = null 
var can_attack = true 

@onready var health_bar = $ProgressBar 
@onready var sprite = $Sprite2D
@onready var detection_area = $DetectionArea
@onready var attack_area = $AttackArea
@onready var attack_timer = $AttackTimer

func _ready():
	health_bar.max_value = hp
	health_bar.value = hp
	add_to_group("Enemy")
	
	if not detection_area.body_entered.is_connected(_on_detection_entered):
		detection_area.body_entered.connect(_on_detection_entered)
		detection_area.body_exited.connect(_on_detection_exited)
		attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if player != null: 
		var direction = (player.global_position - global_position).normalized()
		velocity.x = direction.x * speed
		
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

func attempt_attack():
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.name == "Player": 
			if body.has_method("take_damage"):
				body.take_damage(10) 
				can_attack = false 
				attack_timer.start() 
				
				sprite.modulate = Color(1, 1, 0)
				await get_tree().create_timer(0.2).timeout
				sprite.modulate = Color(0.2, 0, 0.4) 

func _on_attack_timer_timeout(): can_attack = true
func _on_detection_entered(body): if body.name == "Player": player = body
func _on_detection_exited(body): if body.name == "Player": player = null

# ==========================================
# CHỊU SÁT THƯƠNG VÀ CHẾT (CÓ ÂM THANH)
# ==========================================
func take_damage(damage_amount):
	hp -= damage_amount 
	health_bar.value = hp 
	
	sprite.modulate = Color(1, 0, 0) 
	await get_tree().create_timer(0.1).timeout 
	sprite.modulate = Color(0.2, 0, 0.4) 
	
	if hp <= 0:
		# 1. RỚT KINH NGHIỆM CHO PLAYER
		var danh_sach_player = get_tree().get_nodes_in_group("Player")
		if danh_sach_player.size() > 0:
			var player_dang_choi = danh_sach_player[0]
			if player_dang_choi.has_method("gain_exp"):
				player_dang_choi.gain_exp(50)
				
		# 2. BÁO CÁO NHIỆM VỤ
		if Global.danh_sach_nhiem_vu.has("main_01"):
			var nv = Global.danh_sach_nhiem_vu["main_01"]
			if nv["trang_thai"] == 1 and nv["da_lam"] < nv["muc_tieu"]:
				nv["da_lam"] += 1 
				
		# 3. PHÁT ÂM THANH QUÁI CHẾT (Dùng Audio động)
		var file_am_thanh = preload("res://Assets/monster_die.mp3") # SỬA FILE NÀY NẾU CẦN
		if file_am_thanh:
			var may_phat = AudioStreamPlayer.new()
			may_phat.stream = file_am_thanh
			may_phat.volume_db = 5.0 # Tăng tiếng lớn lên 1 chút
			may_phat.process_mode = Node.PROCESS_MODE_ALWAYS # Ép hát ngay cả khi game pause
			get_tree().current_scene.add_child(may_phat)
			may_phat.play()
			may_phat.finished.connect(may_phat.queue_free) # Hát xong tự xóa máy phát
				
		queue_free() # Quái chết bốc hơi
