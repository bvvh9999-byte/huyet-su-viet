extends Area2D

var player_in_zone = false 
var is_opened = false 

@onready var dialog_text = $Label 
@onready var mau_ruong = $ColorRect

func _ready():
	dialog_text.visible = false
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)

func _process(_delta):
	if player_in_zone and not is_opened and Input.is_action_just_pressed("interact"):
		mo_ruong_nguyen_rua()

func mo_ruong_nguyen_rua():
	is_opened = true
	
	# Đổi màu cục gạch sang màu Tím đen xám xịt khi bị mở nắp
	if mau_ruong != null:
		mau_ruong.color = Color(0.2, 0.1, 0.3) 
	
	var ty_le = randf()
	
	# ==========================================
	# 50% XUI XẺO: DÍNH LỜI NGUYỀN!
	# ==========================================
	if ty_le <= 0.5:
		print("=> BẠN BỊ NGUYỀN RỦA!")
		dialog_text.text = "LỜI NGUYỀN: MẤT 50% MÁU!"
		dialog_text.modulate = Color(1, 0, 0) # Chữ Đỏ rực
		
		# Tính toán số máu bị trừ (Dùng float để không báo lỗi số nguyên)
		var mat_mau = int(float(Global.player_hp) / 2.0)
		if mat_mau < 1: 
			mat_mau = 1 # Ít nhất phải mất 1 máu
		
		# Gọi thẳng Player và trừ máu bằng call_deferred (Tuyệt đối an toàn, chống Crash)
		var player_node = get_tree().current_scene.get_node_or_null("Player")
		if player_node and player_node.has_method("take_damage"):
			player_node.call_deferred("take_damage", mat_mau)
			
	# ==========================================
	# 50% MAY MẮN: NHẬN ĐỒ SIÊU XỊN!
	# ==========================================
	else:
		print("=> MAY MẮN! NHẬN ĐƯỢC THÁNH VẬT!")
		dialog_text.text = "NHẬN: Áo Choàng Thánh!"
		dialog_text.modulate = Color(1, 0.8, 0) # Màu vàng kim
		Global.kho_vat_pham.append("Áo Choàng Thánh")
		
	# Bật hiệu ứng chữ nảy lên khỏi rương
	dialog_text.scale = Vector2(1.5, 1.5)
	dialog_text.visible = true

# ==========================================
# CẢM BIẾN PLAYER
# ==========================================
func _on_body_entered(body):
	if body.name == "Player" and not is_opened:
		player_in_zone = true
		dialog_text.text = "[E] Mở Rương (Rủi ro!)"
		dialog_text.modulate = Color(0.8, 0, 1) # Màu tím cảnh báo
		dialog_text.scale = Vector2(1.0, 1.0)
		dialog_text.visible = true 

func _on_body_exited(body):
	if body.name == "Player":
		player_in_zone = false
		dialog_text.visible = false
