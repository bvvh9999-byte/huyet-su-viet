extends CharacterBody2D

var hp = 30 
var speed = 100.0 # Tốc độ chạy của quái
var player = null # Biến nhớ mục tiêu (Player)
var can_attack = true # Biến kiểm tra xem có đang kiệt sức không

@onready var health_bar = $ProgressBar 
@onready var sprite = $Sprite2D
@onready var detection_area = $DetectionArea
@onready var attack_area = $AttackArea
@onready var attack_timer = $AttackTimer

func _ready():
	health_bar.max_value = hp
	health_bar.value = hp
	add_to_group("Enemy")
	
	# Code tự động nối dây Radar và Đồng hồ
	detection_area.body_entered.connect(_on_detection_entered)
	detection_area.body_exited.connect(_on_detection_exited)
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(delta):
	# Trọng lực
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# TRÍ TUỆ NHÂN TẠO (AI)
	if player != null: # Nếu nhìn thấy Player
		# 1. Tính toán hướng chạy về phía Player
		var direction = (player.global_position - global_position).normalized()
		
		# Chỉ cho quái chạy ngang trên mặt đất, không bay lên trời
		velocity.x = direction.x * speed
		
		# 2. Xoay mặt và xoay vùng cắn theo hướng Player
		if direction.x > 0:
			sprite.flip_h = false
			attack_area.scale.x = 1
		elif direction.x < 0:
			sprite.flip_h = true
			attack_area.scale.x = -1
			
		# 3. Kích hoạt cắn
		if can_attack:
			attempt_attack()
	else:
		# Nếu không thấy Player thì đứng im
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

# --- HÀM TẤN CÔNG PLAYER ---
# --- HÀM TẤN CÔNG PLAYER ---
# --- HÀM TẤN CÔNG PLAYER ---
func attempt_attack():
	var bodies = attack_area.get_overlapping_bodies()
	
	# Nếu miệng không chạm vào ai cả, in ra để biết
	if bodies.size() == 0:
		# print("Cái mồm đang cắn vào không khí!") # Tạm tắt để đỡ trôi màn hình
		return
		
	for body in bodies:
		if body.name == "Player": 
			if body.has_method("take_damage"):
				body.take_damage(10) 
				
				print("=> PHẬP! Quái vật đã cắn trúng Player!")
				can_attack = false 
				attack_timer.start() 
				
				sprite.modulate = Color(1, 1, 0)
				await get_tree().create_timer(0.2).timeout
				sprite.modulate = Color(0.2, 0, 0.4)

# KHI ĐỒNG HỒ REO (NGHỈ NGƠI XONG)
func _on_attack_timer_timeout():
	print("=> Đồng hồ reo! Quái vật đã sẵn sàng cắn tiếp!")
	can_attack = true	

# --- RADAR PHÁT HIỆN PLAYER ---
func _on_detection_entered(body):
	if body.name == "Player":
		player = body # Khóa mục tiêu!

func _on_detection_exited(body):
	if body.name == "Player":
		player = null # Player chạy thoát khỏi radar

# --- HÀM TRỪ MÁU KHI BỊ CHÉM ---
func take_damage(damage_amount):
	hp -= damage_amount # Bị chém trừ máu
	health_bar.value = hp # Cập nhật thanh máu trên đầu
	
	# Nháy đỏ
	$Sprite2D.modulate = Color(1, 0, 0) 
	await get_tree().create_timer(0.1).timeout 
	$Sprite2D.modulate = Color(0.2, 0, 0.4) 
	
	# Nếu hết máu thì cho EXP rồi chết
	if hp <= 0:
		var player_node = get_tree().get_first_node_in_group("Player")
		if player_node != null:
			if player_node.has_method("gain_exp"):
				player_node.gain_exp(50) # Cho 50 EXP
				
		queue_free() # Bốc hơi
