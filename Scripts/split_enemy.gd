extends CharacterBody2D

var hp = 50 
var speed = 70.0 
var player = null 
var can_attack = true 

# Đảm bảo đường dẫn này trỏ ĐÚNG vào file quái nhỏ của bạn!
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
	
	if not detection_area.body_entered.is_connected(_on_detection_entered):
		detection_area.body_entered.connect(_on_detection_entered)
		detection_area.body_exited.connect(_on_detection_exited)
		attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(delta):
	if not is_on_floor(): velocity += get_gravity() * delta
		
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
		if body.name == "Player" and body.has_method("take_damage"):
			body.take_damage(15) 
			can_attack = false 
			attack_timer.start() 
			sprite.modulate = Color(1, 1, 1)
			await get_tree().create_timer(0.2).timeout
			sprite.modulate = Color(0.6, 0, 0) 

func _on_attack_timer_timeout(): can_attack = true
func _on_detection_entered(body): if body.name == "Player": player = body
func _on_detection_exited(body): if body.name == "Player": player = null

func take_damage(damage_amount):
	hp -= damage_amount 
	health_bar.value = hp 
	
	sprite.modulate = Color(1, 0, 0) 
	await get_tree().create_timer(0.1).timeout 
	sprite.modulate = Color(0.6, 0, 0) 
	
	if hp <= 0:
		# 1. RỚT EXP
		var danh_sach_player = get_tree().get_nodes_in_group("Player")
		if danh_sach_player.size() > 0:
			if danh_sach_player[0].has_method("gain_exp"):
				danh_sach_player[0].gain_exp(50)
				
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

		# 4. ĐẺ RA 2 CON QUÁI CON TRƯỚC KHI BỐC HƠI
		if small_enemy_scene:
			for i in range(2): 
				var small = small_enemy_scene.instantiate()
				var random_offset = Vector2(randf_range(-40, 40), -20)
				small.global_position = global_position + random_offset
				get_parent().call_deferred("add_child", small)
			
		queue_free()
