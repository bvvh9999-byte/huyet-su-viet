extends Area2D

# Mã nhiệm vụ NPC này quản lý. Bạn có thể thay đổi ở bảng Inspector bên ngoài.
@export var ma_nhiem_vu: String = "main_01" 

var player_in_zone = false 
@onready var dialog_text = $Label 

func _ready():
	# Lúc mới vào game thì giấu chữ đi
	dialog_text.visible = false
	
	# Cắm dây điện tự động cho Radar NPC
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)

# KHI BẤM PHÍM 'E' ĐỂ NÓI CHUYỆN
func _process(delta):
	if player_in_zone and Input.is_action_just_pressed("interact"):
		
		# 1. Kiểm tra xem mã nhiệm vụ (main_01) có tồn tại trong Global không
		if Global.danh_sach_nhiem_vu.has(ma_nhiem_vu):
			var nv = Global.danh_sach_nhiem_vu[ma_nhiem_vu] # Lấy cuốn sổ ra xem
			
			# TRƯỜNG HỢP A: CHƯA NHẬN NHIỆM VỤ
			if nv["trang_thai"] == 0:
				dialog_text.text = "[" + nv["loai"] + "]\nHãy giúp ta tiêu diệt " + str(nv["muc_tieu"]) + " tên giặc!"
				nv["trang_thai"] = 1 # Chuyển sang Đang làm
				print("=> [NPC] ĐÃ GIAO NHIỆM VỤ: ", nv["ten"])
				
			# TRƯỜNG HỢP B: ĐANG LÀM NHIỆM VỤ
			elif nv["trang_thai"] == 1:
				if nv["da_lam"] < nv["muc_tieu"]:
					# Chưa giết đủ
					dialog_text.text = "Ngươi mới diệt được " + str(nv["da_lam"]) + "/" + str(nv["muc_tieu"]) + " tên. Cố lên!"
					print("=> [NPC] Tiến độ hiện tại: ", nv["da_lam"], "/", nv["muc_tieu"])
				else:
					# Đã giết đủ -> TRẢ NHIỆM VỤ
					dialog_text.text = "Tuyệt vời! Ta tặng ngươi: " + nv["phan_thuong"]
					nv["trang_thai"] = 2 # Đánh dấu Đã hoàn thành
					
					# Thêm đồ vào kho người chơi
					Global.kho_vu_khi.append(nv["phan_thuong"]) 
					print("=> [NPC] HOÀN THÀNH NHIỆM VỤ! Đã chuyển ", nv["phan_thuong"], " vào kho đồ.")
					
			# TRƯỜNG HỢP C: ĐÃ TRẢ NHIỆM VỤ TỪ TRƯỚC RỒI
			elif nv["trang_thai"] == 2:
				dialog_text.text = "Cảm ơn ngươi đã bảo vệ bờ cõi."
				print("=> [NPC] Nhiệm vụ này đã làm xong từ trước rồi.")
				
		# 2. NẾU MÃ NHIỆM VỤ BỊ SAI (Ví dụ bạn gõ sai tên trong Inspector)
		else:
			dialog_text.text = "Ta chỉ là dân làng bình thường."
			print("=> [NPC] LỖI: Không tìm thấy nhiệm vụ nào có mã là: ", ma_nhiem_vu)

# ==========================================
# CẢM BIẾN RADAR (KHI PLAYER LẠI GẦN)
# ==========================================
func _on_body_entered(body):
	if body.name == "Player":
		player_in_zone = true
		dialog_text.text = "[E] Trò chuyện"
		dialog_text.visible = true 

func _on_body_exited(body):
	if body.name == "Player":
		player_in_zone = false
		dialog_text.visible = false
