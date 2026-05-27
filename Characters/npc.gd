extends Area2D

@export var ma_nhiem_vu: String = "main_01" 

var player_in_zone = false 
@onready var dialog_text = $Label 

func _ready():
	dialog_text.visible = false
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)

# 👉 ĐÃ SỬA CẢNH BÁO MÀU VÀNG Ở ĐÂY (Thêm dấu _)
func _process(_delta):
	if player_in_zone and Input.is_action_just_pressed("interact"):
		if Global.danh_sach_nhiem_vu.has(ma_nhiem_vu):
			var nv = Global.danh_sach_nhiem_vu[ma_nhiem_vu] 
			
			if nv["trang_thai"] == 0:
				dialog_text.text = "[" + nv["loai"] + "]\nHãy giúp ta tiêu diệt " + str(nv["muc_tieu"]) + " tên giặc!"
				nv["trang_thai"] = 1 
				
			elif nv["trang_thai"] == 1:
				if nv["da_lam"] < nv["muc_tieu"]:
					dialog_text.text = "Ngươi mới diệt được " + str(nv["da_lam"]) + "/" + str(nv["muc_tieu"]) + " tên. Cố lên!"
				else:
					dialog_text.text = "Tuyệt vời! Ta tặng ngươi: " + nv["phan_thuong"]
					nv["trang_thai"] = 2 
					Global.kho_vu_khi.append(nv["phan_thuong"]) 
					
			elif nv["trang_thai"] == 2:
				dialog_text.text = "Cảm ơn ngươi đã bảo vệ bờ cõi."
		else:
			dialog_text.text = "Ta chỉ là dân làng bình thường."

func _on_body_entered(body):
	if body.name == "Player":
		player_in_zone = true
		dialog_text.text = "[E] Trò chuyện"
		dialog_text.visible = true 

func _on_body_exited(body):
	if body.name == "Player":
		player_in_zone = false
		dialog_text.visible = false
