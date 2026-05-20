extends CharacterBody2D

var hp = 30 
var speed = 70.0 # Chạy chậm để lùi lại bắn
var player = null 
var can_shoot = true 

# LOAD SẴN VIÊN ĐẠN (Kiểm tra xem đường dẫn này đúng chỗ bạn lưu file bullet.tscn không nhé)
var bullet_scene = preload("res://Enemies/bullet.tscn")

@onready var health_bar = $ProgressBar 
@onready var sprite = $Sprite2D
@onready var detection_area = $DetectionArea
@onready var shoot_timer = $ShootTimer

func _ready():
	health_bar.max_value = hp
	health_bar.value = hp
	add_to_group("Enemy")
	
	# Cắm dây điện radar và đồng hồ
	detection_area.body_entered.connect(_on_detection_entered)
	detection_area.body_exited.connect(_on_detection_exited)
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if player != null: 
		# Đo khoảng cách từ quái đến Player
		var distance = global_position.distance_to(player.global_position)
		# Tính hướng bay của đạn
		var direction = (player.global_position - global_position).normalized()
		
		# Lật mặt nhìn Player
		sprite.flip_h = direction.x < 0
			
		# NẾU PLAYER Ở XA (Cách hơn 200 pixel) -> ĐỨNG LẠI BẮN
		if distance > 200:
			velocity.x = 0
			if can_shoot:
				shoot(direction) # Bóp cò!
				
		# NẾU PLAYER LẠI GẦN QUÁ -> ĐI LÙI BỎ CHẠY!
		else:
			velocity.x = -direction.x * speed 
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

# --- HÀM BẮN ĐẠN ---
func shoot(dir):
	can_shoot = false
	shoot_timer.start() # Vặn đồng hồ nghỉ 2s
	
	# Hiện ứng nhấp nháy khi bắn
	sprite.modulate = Color(1, 1, 1) 
	
	# Sinh ra viên đạn
	var bullet = bullet_scene.instantiate()
	# Điểm xuất phát của viên đạn là ở giữa bụng con quái vật
	bullet.global_position = global_position 
	# Bơm số liệu hướng bay cho viên đạn
	bullet.direction = dir 
	
	# Ném viên đạn ra ngoài bản đồ
	get_tree().current_scene.add_child(bullet)
	
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(0, 0, 1) # Trở lại màu xanh dương

func _on_shoot_timer_timeout():
	can_shoot = true

func _on_detection_entered(body):
	if body.name == "Player": player = body

func _on_detection_exited(body):
	if body.name == "Player": player = null

func take_damage(damage_amount):
	hp -= damage_amount 
	health_bar.value = hp 
	
	sprite.modulate = Color(1, 0, 0) 
	await get_tree().create_timer(0.1).timeout 
	sprite.modulate = Color(0, 0, 1) 
	
	if hp <= 0:
		# MỚI: BÁO CHO PLAYER BIẾT ĐỂ NHẬN EXP
		var player_node = get_tree().current_scene.get_node_or_null("Player")
		if player_node and player_node.has_method("gain_exp"):
			player_node.gain_exp(50) # Cho 50 EXP (Giết 2 con là lên cấp 2)
			
		queue_free()
