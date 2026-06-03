extends Area2D

# ĐIỀN FILE MAP ẨN CỦA BẠN VÀO ĐÂY NHÉ (Hoặc kéo thả vào ô Inspector)
@export_file("*.tscn") var hidden_map_path: String = "res://Scenes/hidden_world.tscn"

var player_in_zone = false 
var is_opened = false 

@onready var dialog_text = $Label 

func _ready():
	dialog_text.visible = false
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)

func _process(delta):
	if player_in_zone and not is_opened and Input.is_action_just_pressed("interact"):
		mo_ruong()

func mo_ruong():
	is_opened = true
	
	# Đổi màu rương sang xám (Nếu dùng Sprite thì thay bằng lệnh đổi frame nhé)
	$ColorRect.color = Color(0.5, 0.5, 0.5) 
	
	print("\n--- ĐANG MỞ RƯƠNG ---")
	
	# BƯỚC 1: QUAY SỐ XEM CÓ BỊ HÚT VÀO MAP ẨN KHÔNG?
	var ty_le_map_an = randf() # Quay từ 0.0 đến 1.0
	
	# 20% TỶ LỆ DÍNH BẪY BỊ HÚT VÀO MAP ẨN
	if ty_le_map_an <= 0.2:
		print("=> TIÊU RỒI! Rương có chứa Ma Pháp Trận! Đang hút vào Hầm Ngục Ẩn!!!")
		
		dialog_text.text = "CỔNG HẦM NGỤC MỞ!"
		dialog_text.modulate = Color(1, 0, 0) # Chữ Đỏ rực
		dialog_text.scale = Vector2(1.5, 1.5)
		dialog_text.visible = true
		
		# Tạm dừng 1 giây để người chơi kịp đọc dòng chữ kinh hoàng đó rồi mới chuyển map
		await get_tree().create_timer(1.0).timeout 
		
		if hidden_map_path != "":
			get_tree().change_scene_to_file(hidden_map_path)
		else:
			print("=> LỖI: Chưa kéo file Map Ẩn vào ô Inspector!")
		
		return # Bị hút vào rồi thì dừng luôn, không quay Gacha đồ nữa!

	# ========================================================
	
	# BƯỚC 2: NẾU THOÁT ĐƯỢC MAP ẨN (80% CÒN LẠI), BẮT ĐẦU QUAY GACHA TÌM ĐỒ
	var phan_thuong = Global.quay_gacha_ruong()
	print("=> BOOOM! BẠN MỞ RA: ", phan_thuong)
	
	dialog_text.text = "+1 " + phan_thuong
	
	if phan_thuong == "Huyết Kiếm Truyền Thuyết":
		dialog_text.modulate = Color(1, 0, 0)
		dialog_text.scale = Vector2(1.5, 1.5) 
		print("=> HOLLY SH*T! ĐỒ SSR!!!")
		
	elif phan_thuong == "Gươm Rỉ Sét" or phan_thuong == "Lá Bùa Hồi Sinh":
		dialog_text.modulate = Color(0.8, 0, 1)
		dialog_text.scale = Vector2(1.2, 1.2)
		
	else:
		dialog_text.modulate = Color(0, 1, 0)
		dialog_text.scale = Vector2(1.0, 1.0)
		
	dialog_text.visible = true

# ===============================================

func _on_body_entered(body):
	if body.name == "Player" and not is_opened:
		player_in_zone = true
		dialog_text.text = "[E] Mở rương"
		dialog_text.modulate = Color(1, 1, 1) 
		dialog_text.scale = Vector2(1.0, 1.0)
		dialog_text.visible = true 

func _on_body_exited(body):
	if body.name == "Player":
		player_in_zone = false
		dialog_text.visible = false
