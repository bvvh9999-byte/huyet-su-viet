extends CharacterBody2D

var hp = 30 
var speed = 70.0 
var player = null 
var can_shoot = true 

# Đảm bảo đường dẫn này trỏ ĐÚNG vào file viên đạn của bạn!
var bullet_scene = preload("res://Enemies/bullet.tscn")

@onready var health_bar = $ProgressBar 
@onready var sprite = $Sprite2D # AnimatedSprite2D
@onready var detection_area = $DetectionArea
@onready var shoot_timer = $ShootTimer

func _ready():
	health_bar.max_value = hp
	health_bar.value = hp
	add_to_group("Enemy")
	
	if sprite != null: sprite.play("idle")
	
	if not detection_area.body_entered.is_connected(_on_detection_entered):
		detection_area.body_entered.connect(_on_detection_entered)
		detection_area.body_exited.connect(_on_detection_exited)
		shoot_timer.timeout.connect(_on_shoot_timer_timeout)

func _physics_process(delta):
	if not is_on_floor(): velocity += get_gravity() * delta
		
	if player != null: 
		var distance = global_position.distance_to(player.global_position)
		var direction = (player.global_position - global_position).normalized()
		
		sprite.flip_h = direction.x < 0
			
		if distance > 200:
			velocity.x = 0
			if sprite != null and sprite.animation != "attack": sprite.play("idle")
			if can_shoot: shoot(direction)
		else:
			velocity.x = -direction.x * speed 
			if sprite != null: sprite.play("run") # Ảnh đi lùi
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		if sprite != null and sprite.animation != "attack" and sprite.animation != "die":
			sprite.play("idle")

	move_and_slide()

func shoot(dir):
	can_shoot = false
	shoot_timer.start() 
	
	if sprite != null: sprite.play("attack")
	
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position 
		bullet.direction = dir 
		get_tree().current_scene.add_child(bullet)
	
	await get_tree().create_timer(0.2).timeout
	if sprite != null: sprite.play("idle")

func _on_shoot_timer_timeout(): can_shoot = true
func _on_detection_entered(body): if body.name == "Player": player = body
func _on_detection_exited(body): if body.name == "Player": player = null

# --- KHI BỊ CHÉM VÀ CHẾT ---
func take_damage(damage_amount):
	hp -= damage_amount 
	health_bar.value = hp 
	
	sprite.modulate = Color(1, 0, 0) 
	await get_tree().create_timer(0.1).timeout 
	sprite.modulate = Color(1, 1, 1) 
	
	if hp <= 0:
		var player_chinh = get_tree().current_scene.get_node_or_null("Player")
		if player_chinh != null:
			if player_chinh.has_method("gain_exp"):
				player_chinh.gain_exp(50)
				
		var nhiem_vu_dang_lam = ""
		if Global.danh_sach_nhiem_vu["main_01"]["trang_thai"] == 1: nhiem_vu_dang_lam = "main_01"
		elif Global.danh_sach_nhiem_vu["main_02"]["trang_thai"] == 1: nhiem_vu_dang_lam = "main_02"
		
		if nhiem_vu_dang_lam != "":
			var nv = Global.danh_sach_nhiem_vu[nhiem_vu_dang_lam]
			if nv["da_lam"] < nv["muc_tieu"]: nv["da_lam"] += 1 

		var file_am_thanh = preload("res://Assets/monster_die.mp3") 
		if file_am_thanh:
			var may_phat = AudioStreamPlayer.new()
			may_phat.stream = file_am_thanh
			may_phat.volume_db = 5.0 
			may_phat.process_mode = Node.PROCESS_MODE_ALWAYS 
			get_tree().current_scene.add_child(may_phat)
			may_phat.play()
			may_phat.finished.connect(may_phat.queue_free)
			
		if sprite != null: sprite.play("die")
		$CollisionShape2D.set_deferred("disabled", true)
		await get_tree().create_timer(1.0).timeout
		queue_free()
