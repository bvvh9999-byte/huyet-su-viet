extends Area2D

@export var ma_nhiem_vu: String = "main_01" 

var player_in_zone = false 
var dang_doc_thoai = false # Đánh dấu xem có đang chạy chuỗi hội thoại không
var dong_thoai_hien_tai = 0 # Đang đọc đến câu thứ mấy

@onready var dialog_text = $Label 

func _ready():
	dialog_text.visible = false
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)

func _process(_delta):
	# Nếu đứng gần và bấm E
	if player_in_zone and Input.is_action_just_pressed("interact"):
		if Global.danh_sach_nhiem_vu.has(ma_nhiem_vu):
			var nv = Global.danh_sach_nhiem_vu[ma_nhiem_vu]
			
			# 1. TRƯỜNG HỢP: CHƯA NHẬN NHIỆM VỤ (CHẠY CHUỖI HỘI THOẠI)
			if nv["trang_thai"] == 0:
				var chuoi_thoai = nv["thoai_nhan_nv"]
				
				# Nếu chưa đọc hết các câu
				if dong_thoai_hien_tai < chuoi_thoai.size():
					dialog_text.text = chuoi_thoai[dong_thoai_hien_tai] + "\n[E] Tiếp tục"
					dong_thoai_hien_tai += 1
				# Nếu đã đọc đến câu cuối cùng
				else:
					dialog_text.text = "[" + nv["loai"] + "] Đã Nhận!"
					nv["trang_thai"] = 1 # Chốt đơn! Chuyển sang Đang Làm
					dong_thoai_hien_tai = 0 # Reset lại bộ đếm
					
			# 2. TRƯỜNG HỢP: ĐANG LÀM NHIỆM VỤ
			elif nv["trang_thai"] == 1:
				if nv["da_lam"] < nv["muc_tieu"]:
					dialog_text.text = nv["thoai_dang_lam"] + str(nv["da_lam"]) + "/" + str(nv["muc_tieu"])
				else:
					dialog_text.text = nv["thoai_tra_nv"]
					nv["trang_thai"] = 2 
					Global.kho_vu_khi.append(nv["phan_thuong"]) 
					
			# 3. TRƯỜNG HỢP: ĐÃ TRẢ NHIỆM VỤ XONG
			elif nv["trang_thai"] == 2:
				dialog_text.text = nv["thoai_ket_thuc"]
		else:
			dialog_text.text = "Xin chào lữ khách."

func _on_body_entered(body):
	if body.name == "Player":
		player_in_zone = true
		dialog_text.text = "[E] Trò chuyện"
		dialog_text.visible = true 
		dong_thoai_hien_tai = 0 # Reset lại mạch truyện khi bước vào

func _on_body_exited(body):
	if body.name == "Player":
		player_in_zone = false
		dialog_text.visible = false
