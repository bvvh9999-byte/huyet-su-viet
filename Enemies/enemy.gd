extends CharacterBody2D

var hp = 30 
var speed = 100.0 # Tốc độ chạy rượt Player
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
	
	# Ép dán nhãn Enemy
	add_to_group("Enemy")
	
	# Kết nối dây điện AI
	detection_area.body_entered.connect(_on_detection_entered)
	detection_area.body_exited.connect(_on_detection_exited)
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(delta):
	# Trọng lực
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# TRÍ TUỆ NHÂN TẠO (AI)
	if player != null: 
		# Tính hướng chạy tới Player
		var direction = (player.global_position - global_position).normalized()
		velocity.x = direction.x * speed
		
		# Xoay mặt và xoay mồm cắn
		if direction.x > 0:
			sprite.flip_h = false
			attack_area.scale.x = 1
		elif direction.x < 0:
			sprite.flip_h = true
			attack_area.scale.x = -1
			
		if can_attack:
			attempt_attack()
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

# --- HÀM TẤN CÔNG PLAYER ---
func attempt_attack():
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.name == "Player": 
			if body.has_method("take_damage"):
				body.take_damage(10) 
				
				can_attack = false 
				attack_timer.start() 
				
				# Quái nháy vàng khi cắn trúng
				sprite.modulate = Color(1, 1, 0)
				await get_tree().create_timer(0.2).timeout
				sprite.modulate = Color(0.2, 0, 0.4) 

func _on_attack_timer_timeout():
	can_attack = true

# --- RADAR PHÁT HIỆN ---
func _on_detection_entered(body):
	if body.name == "Player":
		player = body

func _on_detection_exited(body):
	if body.name == "Player":
		player = null

# --- HÀM BỊ TRỪ MÁU KHI PLAYER CHÉM ---
func take_damage(damage_amount):
	hp -= damage_amount 
	health_bar.value = hp 
	
	sprite.modulate = Color(1, 0, 0) 
	await get_tree().create_timer(0.1).timeout 
	sprite.modulate = Color(0.2, 0, 0.4) 
	
	if hp <= 0:
		# MỚI: BÁO CHO PLAYER BIẾT ĐỂ NHẬN EXP
		var player_node = get_tree().current_scene.get_node_or_null("Player")
		if player_node and player_node.has_method("gain_exp"):
			player_node.gain_exp(50) # Cho 50 EXP (Giết 2 con là lên cấp 2)
			
		queue_free()
