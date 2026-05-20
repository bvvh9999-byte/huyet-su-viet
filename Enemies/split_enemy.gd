extends CharacterBody2D

var hp = 50 # Máu trâu, chém 5 phát mới chết
var speed = 70.0 # Béo quá nên chạy chậm
var player = null 
var can_attack = true 

# NẠP SẴN CON QUÁI NHỎ VÀO BỤNG (Check lại xem đúng thư mục bạn lưu không nhé)
var small_enemy_scene = preload("res://Enemies/small_enemy.tscn")

@onready var health_bar = $ProgressBar 
@onready var sprite = $Sprite2D
@onready var detection_area = $DetectionArea
@onready var attack_area = $AttackArea
@onready var attack_timer = $AttackTimer

func _ready():
	health_bar.max_value = hp
	health_bar.value = hp
	add_to_group("Enemy")
	
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
				body.take_damage(15) # Boss cắn đau hơn (mất 15 máu)
				can_attack = false 
				attack_timer.start() 
				sprite.modulate = Color(1, 1, 1)
				await get_tree().create_timer(0.2).timeout
				sprite.modulate = Color(0.6, 0, 0) # Trở về màu Boss

func _on_attack_timer_timeout(): can_attack = true
func _on_detection_entered(body): if body.name == "Player": player = body
func _on_detection_exited(body): if body.name == "Player": player = null

# ===============================================
# SỰ KIỆN PHÂN THÂN KHI CHẾT
# ===============================================
func take_damage(damage_amount):
	hp -= damage_amount 
	health_bar.value = hp 
	
	sprite.modulate = Color(1, 0, 0) 
	await get_tree().create_timer(0.1).timeout 
	sprite.modulate = Color(0.6, 0, 0) 
	
	# NẾU MÁU VỀ 0 -> ĐẺ RA 2 CON QUÁI CON RỒI MỚI CHẾT
	if hp <= 0:
		for i in range(2): # Lặp 2 lần để đẻ 2 con
			var small = small_enemy_scene.instantiate()
			
			# Tạo vị trí hơi lệch nhau để 2 con không bị đè dính chặt vào nhau
			var random_offset = Vector2(randf_range(-40, 40), -20)
			small.global_position = global_position + random_offset
			
			# An toàn tuyệt đối: Ép Godot đợi 1 phần nghìn giây rồi mới thả quái con ra 
			# (Để tránh lỗi va chạm vật lý)
			get_parent().call_deferred("add_child", small)
			
	if hp <= 0:
		# MỚI: BÁO CHO PLAYER BIẾT ĐỂ NHẬN EXP
		var player_node = get_tree().current_scene.get_node_or_null("Player")
		if player_node and player_node.has_method("gain_exp"):
			player_node.gain_exp(50) # Cho 50 EXP (Giết 2 con là lên cấp 2)
			
		queue_free()
