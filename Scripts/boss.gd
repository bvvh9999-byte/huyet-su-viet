extends CharacterBody2D

var hp = 200 
var max_hp = 200
var speed = 70.0 # Phase 1 đi chậm rải bước
var phase = 1 
var is_talking = false 

var player = null 
var can_attack = true 

@onready var health_bar = $HealthBar 
@onready var attack_area = $AttackArea
@onready var attack_timer = $AttackTimer
@onready var mau_boss = $ColorRect

# CÁC BIẾN ĐỂ TÌM GIAO DIỆN NGOÀI MAP
var env_modulate = null
var dialog_box = null
var dialog_text = null

func _ready():
	health_bar.max_value = hp
	health_bar.value = hp
	
	# Tìm Player
	player = get_tree().current_scene.get_node_or_null("Player")
	
	# Dùng call_deferred để đợi Map load xong rồi mới đi tìm UI và gáy
	call_deferred("khoi_dong_tran_dau")

func khoi_dong_tran_dau():
	# Đi tìm hiệu ứng phòng và hộp thoại (bạn phải tạo ở BossWorld thì nó mới thấy)
	env_modulate = get_tree().current_scene.get_node_or_null("CanvasModulate")
	dialog_box = get_tree().current_scene.get_node_or_null("UILayer/DialogBox")
	if dialog_box:
		dialog_text = dialog_box.get_node_or_null("DialogText")
		
	boss_noi_chuyen("Kẻ vô danh kia! Khá khen cho ngươi lọt được vào đây!\nHãy để lại mạng sống!")

# ==========================================
# CƠ CHẾ NÓI CHUYỆN (TẠM DỪNG GAME)
# ==========================================
func boss_noi_chuyen(cau_noi):
	is_talking = true
	get_tree().paused = true # Dừng thế giới lại
	if dialog_box and dialog_text:
		dialog_box.visible = true
		dialog_text.text = "BÓNG ĐEN LỊCH SỬ:\n" + cau_noi

func _unhandled_input(event):
	# Nếu đang nói mà Player bấm E -> Tắt thoại, đánh tiếp!
	if is_talking and event.is_action_pressed("interact"):
		if dialog_box: dialog_box.visible = false
		is_talking = false
		get_tree().paused = false 
		
		if hp <= 0:
			queue_free() # Tắt thoại trăng trối xong thì biến mất
		elif phase == 2:
			kich_hoat_phase_2()

# ==========================================
# CƠ CHẾ CHỊU ĐÒN VÀ CHUYỂN PHASE
# ==========================================
func take_damage(amount):
	if is_talking: return # Đang gáy thì cấm chém lén!
	
	hp -= amount
	health_bar.value = hp
	
	mau_boss.color = Color(1, 1, 1) # Nháy trắng
	await get_tree().create_timer(0.1).timeout
	if phase == 1: mau_boss.color = Color(0.2, 0, 0.4) # Trở lại Tím Đen
	else: mau_boss.color = Color(1, 0, 0) # Trở lại Đỏ Rực
	
	# CHUYỂN PHASE KHI MÁU XUỐNG DƯỚI 50%
	if hp <= max_hp / 2 and phase == 1:
		phase = 2
		boss_noi_chuyen("NGƯƠI LÀM TA NỔI GIẬN RỒI!\nHÃY NẾM MÙI ĐỊA NGỤC ĐI!!!")
		
	if hp <= 0:
		boss_noi_chuyen("Không thể nào... Lịch sử không thể thay đổi...\nAAAAAAAAA!!!")

func kich_hoat_phase_2():
	# Đổi màu cả phòng sang ĐỎ RỰC
	if env_modulate: env_modulate.color = Color(0.8, 0.2, 0.2)
	
	# Boss hóa khổng lồ và chạy nhanh hơn
	scale = Vector2(1.5, 1.5)
	mau_boss.color = Color(1, 0, 0) # Đổi da thành màu Đỏ
	speed = 180.0

# ==========================================
# AI RƯỢT ĐUỔI VÀ TẤN CÔNG
# ==========================================
func _physics_process(delta):
	if get_tree().paused or is_talking: return 
	
	if not is_on_floor(): velocity += get_gravity() * delta
	
	if player != null:
		var direction = (player.global_position - global_position).normalized()
		velocity.x = direction.x * speed
		
		# Căn chỉnh mồm
		if direction.x > 0: attack_area.scale.x = 1
		elif direction.x < 0: attack_area.scale.x = -1
			
		if can_attack:
			var bodies = attack_area.get_overlapping_bodies()
			for b in bodies:
				if b.name == "Player" and b.has_method("take_damage"):
					var dam = 15 if phase == 1 else 35 # Phase 2 cắn cực thấu xương!
					b.take_damage(dam)
					can_attack = false
					attack_timer.start()
	move_and_slide()

func _on_attack_timer_timeout(): 
	can_attack = true
