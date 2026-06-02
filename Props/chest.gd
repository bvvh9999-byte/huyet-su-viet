extends Area2D

var player_in_zone = false 
var is_opened = false 

@onready var dialog_text = $Label 

func _ready():
	dialog_text.visible = false
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)

func _process(delta):
	# Nếu đứng gần, rương chưa mở và bấm phím E
	if player_in_zone and not is_opened and Input.is_action_just_pressed("interact"):
		mo_ruong()

func mo_ruong():
	is_opened = true
	
	# --- CẬP NHẬT HÌNH ẢNH RƯƠNG MỞ ---
	# Nếu bạn dùng Ảnh Pixel Sprite2D thì dùng dòng 1 (Xóa dấu # đi)
	# $Sprite2D.frame = 1 
	
	# Nếu bạn vẫn đang dùng Khối màu Vàng ColorRect thì dùng dòng 2 (Xóa dấu # đi)
	$ColorRect.color = Color(0.5, 0.5, 0.5) 
	
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
		# Đồ Hiếm (10%): Chữ Tím mộng mơ
		dialog_text.modulate = Color(0.8, 0, 1)
		dialog_text.scale = Vector2(1.2, 1.2)
		
	else:
		# Đồ Thường (Bình Máu, Kiếm Gỗ): Chữ Xanh lá cây hoặc Trắng bình thường
		dialog_text.modulate = Color(0, 1, 0)
		dialog_text.scale = Vector2(1.0, 1.0)
		
	dialog_text.visible = true

func _on_body_entered(body):
	if body.name == "Player" and not is_opened:
		player_in_zone = true
		dialog_text.text = "[E] Mở rương"
		dialog_text.modulate = Color(1, 1, 1) # Màu trắng
		dialog_text.scale = Vector2(1.0, 1.0)
		dialog_text.visible = true 

func _on_body_exited(body):
	if body.name == "Player":
		player_in_zone = false
		dialog_text.visible = false
