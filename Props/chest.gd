extends Area2D

var player_in_zone = false 
var is_opened = false 

@onready var dialog_text = $Label 

# 👉 CHÚ Ý ĐIỂM NÀY: Gọi đến AnimatedSprite2D
@onready var hinh_ruong = $Sprite2D

func _ready():
	dialog_text.visible = false
	
	# Ép rương nằm im lúc mới vào game
	if hinh_ruong != null:
		hinh_ruong.play("idle")
		
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)

func _process(_delta):
	# Nếu đứng gần, rương chưa mở và bấm E
	if player_in_zone and not is_opened and Input.is_action_just_pressed("interact"):
		mo_ruong()

func mo_ruong():
	is_opened = true
	dialog_text.visible = false # Giấu chữ [E] đi để nhường chỗ cho hiệu ứng
	
	# ==========================================
	# 1. BẬT HIỆU ỨNG RƯƠNG BUNG NẮP (TỎA SÁNG)
	# ==========================================
	if hinh_ruong != null:
		hinh_ruong.play("open") 
		
	# Đợi 0.5 giây cho cái rương từ từ hé nắp ra rồi mới văng đồ
	await get_tree().create_timer(0.5).timeout
	
	# ==========================================
	# 2. BẮT ĐẦU QUAY GACHA VÀ RỚT ĐỒ
	# ==========================================
	print("\n--- ĐANG QUAY GACHA ---")
	
	# GỌI THUẬT TOÁN TỪ GLOBAL
	var phan_thuong = Global.quay_gacha_ruong()
	print("=> BOOOM! BẠN MỞ RA: ", phan_thuong)
	
	# --- HIỆU ỨNG HIỂN THỊ TÙY THEO ĐỘ HIẾM ---
	dialog_text.text = "+1 " + phan_thuong
	
	if phan_thuong == "Huyết Kiếm Truyền Thuyết":
		# Đồ Siêu Hiếm (2%): Chữ To bự, màu Đỏ Cờ rực rỡ
		dialog_text.modulate = Color(1, 0, 0)
		dialog_text.scale = Vector2(1.5, 1.5) 
		print("=> HOLLY SH*T! ĐỒ SSR!!!")
		
	elif phan_thuong == "Gươm Rỉ Sét" or phan_thuong == "Lá Bùa Hồi Sinh":
		# Đồ Hiếm (10%): Chữ Vàng Kim sang chảnh
		dialog_text.modulate = Color(1, 0.8, 0)
		dialog_text.scale = Vector2(1.2, 1.2)
		
	else:
		# Đồ Thường (Bình Máu, Kiếm Gỗ): Chữ Xanh lá cây hoặc Trắng bình thường
		dialog_text.modulate = Color(0, 1, 0)
		dialog_text.scale = Vector2(1.0, 1.0)
		
	# Nảy chữ phần thưởng lên màn hình
	dialog_text.visible = true
	
	# Tùy chọn: Chữ từ từ bay lên cao rồi biến mất (Trông xịn hơn)
	var tween = create_tween()
	tween.tween_property(dialog_text, "position:y", dialog_text.position.y - 50, 1.5)
	tween.tween_property(dialog_text, "modulate:a", 0.0, 1.5) # Mờ dần

# ==========================================
# CẢM BIẾN PLAYER LẠI GẦN
# ==========================================
func _on_body_entered(body):
	if body.name == "Player" and not is_opened:
		player_in_zone = true
		
		# Hiện chữ [E] nhắc nhở
		dialog_text.text = "[E] Mở rương"
		dialog_text.modulate = Color(1, 1, 1, 1) # Trắng đục
		dialog_text.scale = Vector2(1.0, 1.0)
		# Đặt lại vị trí chữ nhỡ nó bay đi mất
		dialog_text.position = Vector2(-40, -40) 
		dialog_text.visible = true 

func _on_body_exited(body):
	if body.name == "Player" and not is_opened:
		player_in_zone = false
		dialog_text.visible = false
