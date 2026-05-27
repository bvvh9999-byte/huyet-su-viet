extends CharacterBody2D

# ==========================================
# THÔNG SỐ CƠ BẢN
# ==========================================
@export var SPEED = 200.0
@export var JUMP_VELOCITY = -400.0
@export var DASH_SPEED = 600.0

var is_dashing = false
var is_attacking = false
var facing_right = true

# ==========================================
# KẾT NỐI GIAO DIỆN (UI) VÀ NODE
# ==========================================
@onready var sprite = $Sprite2D
@onready var dash_timer = $DashTimer
@onready var sword_hitbox = $SwordHitbox
@onready var sword_visual = $SwordHitbox/ColorRect

# HUD trên màn hình
@onready var health_bar = $CanvasLayer/HealthBar
@onready var exp_bar = $CanvasLayer/ExpBar
@onready var quest_tracker = $CanvasLayer/QuestTracker 

# Tải sẵn các màn hình 
var game_over_scene = preload("res://UI/game_over_screen.tscn")
var level_up_scene = preload("res://UI/level_up_screen.tscn")
var profile_scene = preload("res://UI/profile_screen.tscn")
var profile_instance = null 

func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	sword_hitbox.body_entered.connect(_on_sword_hit_something)
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	
	sword_visual.visible = false
	sword_hitbox.monitoring = false
	
	health_bar.max_value = Global.max_hp
	health_bar.value = Global.player_hp
	
	if exp_bar != null:
		exp_bar.max_value = Global.exp_to_next_level
		exp_bar.value = Global.player_exp

# ==========================================
# HÀM BẮT BÀN PHÍM CHÍNH (MIỄN NHIỄM PAUSE)
# ==========================================
func _unhandled_input(event):
	if event.is_action_pressed("open_profile"):
		if profile_instance == null:
			if profile_scene:
				profile_instance = profile_scene.instantiate()
				get_tree().root.add_child(profile_instance)
				get_tree().paused = true 
		else:
			profile_instance.queue_free()
			profile_instance = null
			get_tree().paused = false 

# ==========================================
# HỆ THỐNG VẬT LÝ VÀ CHẠY NHẢY 
# ==========================================
func _physics_process(delta):
	if get_tree().paused:
		return 
		
	if is_dashing:
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("attack") and not is_attacking and is_on_floor():
		attack()
		return

	if is_attacking:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
		return

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("dash") and is_on_floor():
		start_dash()
		return

	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		if direction > 0:
			sprite.flip_h = false
			facing_right = true
			sword_hitbox.scale.x = 1
		elif direction < 0:
			sprite.flip_h = true
			facing_right = false
			sword_hitbox.scale.x = -1
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	if quest_tracker != null:
		var hien_thi_chu = ""
		for ma_nv in Global.danh_sach_nhiem_vu:
			var nv = Global.danh_sach_nhiem_vu[ma_nv]
			if nv["trang_thai"] == 1:
				hien_thi_chu += "- " + nv["ten"] + " [" + str(nv["da_lam"]) + "/" + str(nv["muc_tieu"]) + "]\n"
		quest_tracker.text = hien_thi_chu

# ==========================================
# CHIẾN ĐẤU VÀ KỸ NĂNG
# ==========================================
func attack():
	is_attacking = true
	sword_visual.visible = true
	sword_hitbox.monitoring = true 
	
	await get_tree().physics_frame
	
	var bodies = sword_hitbox.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage") and body != self:
			var tong_sat_thuong = 10 + Global.bonus_damage 
			body.take_damage(tong_sat_thuong)
			
	await get_tree().create_timer(0.2).timeout
	sword_hitbox.monitoring = false
	sword_visual.visible = false
	is_attacking = false

# 👉 ĐÃ SỬA CẢNH BÁO MÀU VÀNG Ở ĐÂY (Thêm dấu _)
func _on_sword_hit_something(_body):
	pass

func start_dash():
	is_dashing = true
	velocity.y = 0
	if facing_right: velocity.x = DASH_SPEED
	else: velocity.x = -DASH_SPEED
	dash_timer.start()

func _on_dash_timer_timeout():
	is_dashing = false

# ==========================================
# CHỊU SÁT THƯƠNG VÀ LÊN CẤP
# ==========================================
func take_damage(amount):
	Global.player_hp -= amount
	health_bar.value = Global.player_hp
	
	sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1)
	
	if Global.player_hp <= 0:
		if game_over_scene:
			var game_over = game_over_scene.instantiate()
			get_tree().root.add_child(game_over)
			get_tree().paused = true 

func gain_exp(amount):
	Global.player_exp += amount
	
	if Global.player_exp >= Global.exp_to_next_level:
		Global.player_level += 1
		Global.player_exp -= Global.exp_to_next_level 
		Global.exp_to_next_level += 50 
		
		if level_up_scene:
			var lvl_up = level_up_scene.instantiate()
			get_tree().root.add_child(lvl_up)
			get_tree().paused = true 

	if exp_bar != null:
		exp_bar.max_value = Global.exp_to_next_level
		exp_bar.value = Global.player_exp
		health_bar.max_value = Global.max_hp
		health_bar.value = Global.player_hp
